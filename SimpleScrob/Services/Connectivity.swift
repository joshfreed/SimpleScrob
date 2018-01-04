//
//  Connectivity.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/15/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import Alamofire

protocol Connectivity {
    var isConnectedToInternet: Bool { get }
}

class AlamofireConnectivity: Connectivity {
    var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
