//
//  User.swift
//  PersonRez
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import Foundation
import RealmSwift

//local user
struct User {
    var name: String
    var image: UIImage
    var time: String
    //var confidence: String
}

//upload user
struct Users: Codable {
    var name: String
    var imageURL: String
    var time: String
}

class SavedVector: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var vector: String = ""
    @objc dynamic var distance: Double = 0
}
