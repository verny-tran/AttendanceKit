//
//  LogTableViewCell.swift
//  PersonRez
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit

class LogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
