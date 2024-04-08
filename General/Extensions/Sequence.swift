//
//  Sequence.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    public func unique() -> [Iterator.Element] {
        var seen = Set<Iterator.Element>()
        return filter { seen.update(with: $0) == nil }
    }
}
