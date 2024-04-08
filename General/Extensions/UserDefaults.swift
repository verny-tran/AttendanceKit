//
//  UserDefaults.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 26/12/2023.
//

import Foundation

extension UserDefaults {
    public static var savedUsers: [String] = UserDefaults.standard.stringArray(forKey: Constant.savedUsers) ?? [String]()
}
