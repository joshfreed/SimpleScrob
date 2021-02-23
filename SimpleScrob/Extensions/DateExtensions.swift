//
//  DateExtensions.swift
//  SimpleScrob
//
//  Created by Josh Freed on 2/23/21.
//  Copyright © 2021 Josh Freed. All rights reserved.
//

import Foundation

extension Date {
    public static func makeDate(from string: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.date(from: string)
    }
    
    public func jpfShortTimeAgo(since: Date) -> String {
        let calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfYear, .month, .year])
        var earliest: Date
        var latest: Date
        if self.timeIntervalSince1970 < since.timeIntervalSince1970 {
            earliest = self
            latest = since
        } else {
            earliest = since
            latest = self
        }
        
        let components = calendar.dateComponents(unitFlags, from: earliest, to: latest)
        
        if (components.year! > 0) {
            return "\(components.year!)y"
        } else if (components.month! > 0) {
            return "\(components.month!)mo"
        } else if (components.weekOfYear! > 0) {
            return "\(components.weekOfYear!)w"
        } else if (components.day! > 0) {
            return "\(components.day!)d"
        } else if (components.hour! > 0) {
            return "\(components.hour!)h"
        } else if (components.minute! > 0) {
            return "\(components.minute!)m"
        } else {
            return "\(components.second!)s"
        }
    }
}
