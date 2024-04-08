//
//  LecturersController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 16/03/2024.
//

import General
import UIKit

import RxCocoa
import RxSwift

class LecturersController: UIViewController, UISearchBarDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResult = BehaviorRelay<[String : [String : Any]]>(value: [:])
    let disposeBag = DisposeBag()
        
    var lecturerName: String?
    var lecturerID: String?
    
    var identifiers = [String]()
    var lecturers = [String : [String : Any]]() {
        didSet {
            self.identifiers = self.lecturers.map({ $0.key })
            self.searchResult.accept(self.lecturers)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardInteractively()
        self.binding()
        
        self.tableView.delegate = self
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        guard Reachability.isConnectedToInternet
        else { return self.showDialog(message: "You have not connected to internet. Using local data.") }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "LecturerController": let lecturerController = segue.destination as? LecturerController
            lecturerController?.lecturerName = self.lecturerName
            lecturerController?.lecturerID = self.lecturerID
            
        case "AssignController": let assignController = segue.destination as? AssignController
            assignController?.lecturerName = self.lecturerName
            assignController?.lecturerID = self.lecturerID
            
        default: break
        }
    }
    
    @objc
    private func refresh() {
        self.tableView.refreshControl?.beginRefreshing()
        
        Firebase.manager.loadLecturers { [weak self] lecturers in
            guard let `self` = self else { return }
            
            self.lecturers = lecturers
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func binding()  {
        self.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
            .distinctUntilChanged().subscribe(onNext: { query in
                let filteredLecturers = self.lecturers.filter { $0.key.lowercased().hasPrefix(query.lowercased()) }
                self.searchResult.accept(filteredLecturers)
            }).disposed(by: self.disposeBag)
        
        self.searchResult.asObservable().bind(to: self.tableView.rx.items(
            cellIdentifier: "cellID", cellType: UITableViewCell.self
        )) { row, data, cell in
            guard let name = data.value["name"] else { return }
            cell.textLabel?.text = "\(data.key). \(name)"
        }.disposed(by: self.disposeBag)
    }
}

extension LecturersController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let lecturerID = self.identifiers[indexPath.row]
        guard let lecturerName = self.lecturers[lecturerID]?["name"] as? String else { return }
        
        self.lecturerID = lecturerID
        self.lecturerName = lecturerName
        
        let alert = UIAlertController(title: "\(lecturerID). \(lecturerName)", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Assign class", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "AssignController", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let id = self.identifiers[indexPath.row]
        
        guard let name = self.lecturers[id]?["name"] as? String else { return nil }
        
        let action = UIContextualAction(style: .normal, title: "Modify") { _,_,_ in
            self.lecturerID = id
            self.lecturerName = name
            
            self.performSegue(withIdentifier: "LecturerController", sender: nil)
        }
        
        action.backgroundColor = UIColor(named: "DarkBlueColor")

        return UISwipeActionsConfiguration(actions: [action])
    }
}
