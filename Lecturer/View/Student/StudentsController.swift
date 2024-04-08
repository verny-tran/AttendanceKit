//
//  StudentsController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import General
import UIKit

import RxCocoa
import RxSwift

class StudentsController: UIViewController, UISearchBarDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResult = BehaviorRelay<[String: [String : Any]]>(value: [:])
    let disposeBag = DisposeBag()
        
    var studentName: String?
    var studentID: String?
    
    var identifiers = [String]()
    var students = [String : [String : Any]]() {
        didSet {
            self.identifiers = self.students.map({ $0.key })
            self.searchResult.accept(self.students)
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
        case "ReportController": let reportController = segue.destination as? ReportController
            reportController?.studentID = self.studentID
            reportController?.studentName = self.studentName
            
        default: break
        }
    }
    
    @objc
    private func refresh() {
        self.tableView.refreshControl?.beginRefreshing()
        
        Firebase.manager.loadStudents { [weak self] students in
            guard let `self` = self else { return }
            self.students = students
            
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func binding()  {
        self.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
            .distinctUntilChanged().subscribe(onNext: { query in
                let filteredStudents = self.students.filter { $0.key.lowercased().hasPrefix(query.lowercased()) }
                self.searchResult.accept(filteredStudents)
            }).disposed(by: self.disposeBag)
        
        self.searchResult.asObservable().bind(to: self.tableView.rx.items(
            cellIdentifier: "cellID", cellType: UITableViewCell.self
        )) { row, data, cell in
            guard let name = data.value["name"] else { return }
            cell.textLabel?.text = "\(data.key). \(name)"
        }.disposed(by: self.disposeBag)
    }
}

extension StudentsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let studentID = self.identifiers[indexPath.row]
        guard let studentName = self.students[studentID]?["name"] as? String else { return }
        
        self.studentID = studentID
        self.studentName = studentName
        
        let alert = UIAlertController(title: "\(studentID). \(studentName)", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "See attendance report", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "ReportController", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
