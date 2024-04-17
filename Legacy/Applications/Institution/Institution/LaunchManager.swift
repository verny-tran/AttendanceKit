//
//  LaunchManager.swift
//  Student
//
//  Created by Trần T. Dũng  on 02/08/2022.
//

import Foundation

enum LaunchPhase {
    case first
    case second
    case last
}

final class LaunchManager: ObservableObject {
    @Published private(set) var state: LaunchPhase = .first
    
    func dismiss() {
        if self.state == .first {
            self.state = .second
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.state = .last
        }
    }
}
