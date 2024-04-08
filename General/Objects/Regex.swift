//
//  Regex.swift
//  General
//
//  Created by Dũng/Verny/서비스개발팀 on 13/03/2024.
//

import Foundation

enum Regex: String {
    case blank = "^(?!\\s*$).+"
    case nickname = "^(?![0-9]+$)[a-z0-9._]{4,30}$"
    case nicknameLength = "^.{4,30}$"
    case hashtag = "^[#|@]+[^\\s!@#$%^&*()=+./,\\[{\\]};:'\"?><]+$"
    case phoneNumber = "^[+]?[(]?[0-9]{2,3}[)]?[-s.]?[0-9]{3,4}[-s.]?[0-9]{3,6}$"
    case link = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
    
    case betweenHashes = "#(.*?)#"
    case betweenQuotationMarks = "\"(.*?)\""
    
    var pattern: String { return self.rawValue }
    
    func validate(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        let regex = try? NSRegularExpression(pattern: self.pattern)
        if regex?.firstMatch(in: string, options: [], range: range) != nil { return true }
        else { return false }
    }
}
