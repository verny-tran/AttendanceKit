//
//  ScheduleController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 17/03/2024.
//

import General

class ScheduleController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    var studentName: String?
    var studentID: String?
    
    var identifiers = [String]()
    
    var classes = [String : Any]() {
        didSet { self.identifiers = self.classes.map({ $0.key }) }
    }
    
    var students = [String : [String : Any]]() {
        didSet {
            guard let studentID = self.studentID else { return }
            self.classes = self.students[studentID]?["classes"] as? [String : Any] ?? [:]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLabel.text = self.studentName
        self.idLabel.text = self.studentID
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        self.refresh()
    }
    
    @IBAction func buttonAssign(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ClassesController")
        
        guard let classesController = viewController as? ClassesController else { return }
        classesController.onSelect = { [weak self] `class` in
            guard let `self` = self else { return }
            
            guard let studentID = self.studentID else { return }
            self.students[studentID]?["classes"] = `class`
            
            Firebase.manager.uploadStudentClass((studentID, `class`), completion: { [weak self] in
                guard let `self` = self else { return }
                
                self.showDialog(message: "Assign class to student successfully!")
                self.refresh()
            })
        }
        
        self.present(classesController, animated: true)
    }
    
    @objc
    private func refresh() {
        self.tableView.refreshControl?.beginRefreshing()
        
        Firebase.manager.loadStudents() { [weak self] students in
            guard let `self` = self else { return }
            self.students = students
            
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension ScheduleController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let studentID = self.studentID,
              let classes = self.students[studentID]?["classes"] as? [String : Any] else { return 0 }
        
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let id = self.identifiers[indexPath.row]
        
        guard let `class` = self.classes[id] as? [String : Any], let name = `class`["name"] else { return cell }
        cell.selectionStyle = .none
        cell.textLabel?.text = "\(id). \(name)"
        
        return cell
    }
}

