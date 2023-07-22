//
//  Duration.swift
//  Statter
//
//  Created by gandreas on 7/21/23.
//

import Foundation

extension Optional where Wrapped == Int {
    var timeValue: String {
        guard let intValue = self else {
            return "-:--"
        }
        return "\(intValue / 1000 / 60):\(String(format:"%.2i", (intValue / 1000) % 60))"
    }
}

// for now
typealias Duration = String
