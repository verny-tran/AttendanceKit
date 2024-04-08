//
//  AssignController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 16/03/2024.
//

import General

class AssignController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    var lecturerName: String?
    var lecturerID: String?
    
    var identifiers = [String]()
    
    var classes = [String : Any]() {
        didSet { self.identifiers = self.classes.map({ $0.key }) }
    }
    
    var lecturers = [String : [String : Any]]() {
        didSet {
            guard let lecturerID = self.lecturerID else { return }
            self.classes = self.lecturers[lecturerID]?["classes"] as? [String : Any] ?? [:]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLabel.text = self.lecturerName
        self.idLabel.text = self.lecturerID
        
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
            
            guard let lecturerID = self.lecturerID else { return }
            self.lecturers[lecturerID]?["classes"] = `class`
            
            Firebase.manager.uploadLecturerClass((lecturerID, `class`), completion: { [weak self] in
                guard let `self` = self else { return }
                
                self.showDialog(message: "Assign class to lecturer successfully!")
                self.refresh()
            })
        }
        
        self.present(classesController, animated: true)
    }
    
    @objc
    private func refresh() {
        self.tableView.refreshControl?.beginRefreshing()
        
        Firebase.manager.loadLecturers() { [weak self] lecturers in
            guard let `self` = self else { return }
            self.lecturers = lecturers
            
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension AssignController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lecturerID = self.lecturerID,
              let classes = self.lecturers[lecturerID]?["classes"] as? [String : Any] else { return 0 }
        
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
