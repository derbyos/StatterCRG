//
//  Duration.swift
//  Statter
//
//  Created by gandreas on 7/21/23.
//

import Foundation

extension Optional where Wrapped == Int {
    public var timeValue: String {
        guard let intValue = self else {
            return "-:--"
        }
        return "\(intValue / 1000 / 60):\(String(format:"%.2i", (intValue / 1000) % 60))"
    }
}

// for now
public typealias Duration = Int

/// Absolute wall time
public typealias WallTime = Int
/// Relative to the current period clock
public typealias PeriodTime = Int
/// Relative to the current jam clock
public typealias JamTime = Int
