//
//  NetworkChecker.swift
//  PersonRecognize
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import Foundation
import Alamofire

struct NetworkChecker {
  static let sharedInstance = NetworkReachabilityManager()!
  static var isConnectedToInternet:Bool {
      return self.sharedInstance.isReachable
    }
}
