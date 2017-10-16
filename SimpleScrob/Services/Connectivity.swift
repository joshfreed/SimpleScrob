//
//  Connectivity.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/15/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    class var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
