//
//  UISearchBar.swift
//  General
//
//  Created by Dũng/Verny/서비스개발팀 on 16/03/2024.
//

import UIKit

extension UISearchBar {
    public var placeholderLabel: UILabel {
        for case let label as UILabel in self.searchTextField.subviews { return label }
        return UILabel()
    }
    
    public var searchField: UITextField? {
        return self.value(forKey: "searchField") as? UITextField
    }
    
    public var clearButton: UIButton? {
        return self.searchField?.value(forKey: "_clearButton") as? UIButton
    }
}
