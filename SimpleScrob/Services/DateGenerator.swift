//
//  DateGenerator.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/8/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import UIKit

class DateGenerator {
    var now: Date {
        return Date()
    }
    
    func currentDate() -> Date {
        return Date()
    }
    
    func date(timeIntervalSince1970: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }
}
