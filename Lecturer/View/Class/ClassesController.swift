//
//  ClassesController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 17/03/2024.
//

import General
import UIKit

import RxCocoa
import RxSwift

class ClassesController: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResult = BehaviorRelay<[String : [String : Any]]>(value: [:])
    let disposeBag = DisposeBag()
    
    private var lecturerID: String? { UserDefaults.standard.value(forKey: "lecturerID") as? String }
    
    var classID: String?
    var className: String?
    var room: String?
    var duration: TimeInterval?
    
    var identifiers = [String]()
    var classes = [String : [String : Any]]() {
        didSet {
            self.identifiers = self.classes.map({ $0.key })
            self.searchResult.accept(self.classes)
        }
    }
    
    var onSelect: (([String : [String : Any]]) -> Void)?
    
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
        case "ClassController": let classController = segue.destination as? ClassController
            classController?.classID = self.classID
            classController?.className = self.className
            classController?.room = self.room
            classController?.duration = self.duration
            
        default: break
        }
    }
    
    @objc
    private func refresh() {
        guard let lecturerID = self.lecturerID else { return }
        self.tableView.refreshControl?.beginRefreshing()
        
        Firebase.manager.loadClasses(lecturer: lecturerID) { [weak self] classes in
            guard let `self` = self else { return }
            self.classes = classes
            
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func binding() {
        self.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
            .distinctUntilChanged().subscribe(onNext: { query in
                let filteredLecturers = self.classes.filter { $0.key.lowercased().hasPrefix(query.lowercased()) }
                self.searchResult.accept(filteredLecturers)
            }).disposed(by: self.disposeBag)
        
        self.searchResult.asObservable().bind(to: self.tableView.rx.items(
            cellIdentifier: "cellID", cellType: UITableViewCell.self
        )) { row, data, cell in
            guard let name = data.value["name"] as? String else { return }
            cell.textLabel?.text = "\(data.key). \(name)"
        }.disposed(by: self.disposeBag)
    }
}

extension ClassesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let id = self.identifiers[indexPath.row]
        
        guard let room = self.classes[id]?["room"] as? String,
              let name = self.classes[id]?["name"] as? String,
              let duration = self.classes[id]?["duration"] as? TimeInterval else { return nil }
        
        let action = UIContextualAction(style: .normal, title: "Modify") { _,_,_ in
            self.classID = id
            self.className = name
            self.room = room
            self.duration = duration
            
            self.performSegue(withIdentifier: "ClassController", sender: nil)
        }
        
        action.backgroundColor = UIColor(named: "DarkBlueColor")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}
