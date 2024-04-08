//
//  Reachability.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import Foundation
import Alamofire

public struct Reachability {
    public static let `default` = NetworkReachabilityManager()!
    
    public static var isConnectedToInternet: Bool { self.default.isReachable }
}
