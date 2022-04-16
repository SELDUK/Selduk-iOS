//
//  String+Extension.swift
//  Seldeog
//
//  Created by 권준상 on 2022/04/09.
//

import Foundation

extension String {
    
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) { return date } else { return nil }
    }
}
