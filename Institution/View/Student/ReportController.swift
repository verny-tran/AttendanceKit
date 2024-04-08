//
//  ReportController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 16/03/2024.
//

import General
import Charts
import SwiftUI

class ReportCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    
    func configure(with view: UIView) {
        self.containerView.subviews.forEach { $0.removeFromSuperview() }
        self.containerView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
    }
}

class ReportController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    struct Duration: Identifiable {
        let id = UUID()
        
        var date: String
        var duration: TimeInterval
    }
    
    var studentName: String?
    var studentID: String?
    
    private var durations = [String : [String : TimeInterval]]()
    
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
    
    @objc
    private func refresh() {
        guard let studentID = self.studentID else { return }
        self.tableView.refreshControl?.beginRefreshing()
        
        Firebase.manager.loadAttendances(of: studentID, completion: { [weak self] durations in
            guard let `self` = self else { return }
            self.durations = durations
            
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        })
    }
    
    private func chart(of duration: (class: String, values: [String : TimeInterval])) -> UIHostingController<some View> {
        let durations = duration.values.map({ Duration(date: $0.key, duration: $0.value) })
        
        let view = VStack {
            Text(duration.class)
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Chart {
                ForEach(durations) { duration in
                    BarMark(x: .value("Date", duration.date),
                            y: .value("Seconds", duration.duration))
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
                }
            }
        }
        
        let hostingController = UIHostingController(rootView: view)
        self.addChild(hostingController)
        
        return hostingController
    }
}

extension ReportController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.durations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as? ReportCell
        else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        
        let identifier = self.durations.keys.map({ $0 })[indexPath.row]
        guard let durations = self.durations[identifier] else { return cell }
        
        let chart = self.chart(of: (identifier, durations))
        cell.configure(with: chart.view)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
}
