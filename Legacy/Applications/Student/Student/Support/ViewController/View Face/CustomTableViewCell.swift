//
//  CustomTableViewCell.swift
//  PersonRez
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
