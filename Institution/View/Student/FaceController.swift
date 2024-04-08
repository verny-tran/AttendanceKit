//
//  FaceController.swift
//  Institution
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit
import General

class FaceCell: UITableViewCell {
    @IBOutlet weak var faceImageView: UIImageView!
}

class FaceController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    var images = [UIImage?]()
    
    var studentName: String?
    var studentID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLabel.text = self.studentName
        self.idLabel.text = self.studentID
        
        guard let studentID = self.studentID else { return }
        self.images = Frame.ImageDataset.training.images(of: studentID)
        self.title = "\(self.images.count) image frames"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension FaceController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as? FaceCell
        else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.faceImageView?.image = self.images[indexPath.row]
        
        return cell
    }
}
