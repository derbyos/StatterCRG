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

public func format(wallTime: WallTime) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(wallTime) / 1000)
    return date.formatted(date: .omitted, time: .standard)
}
public extension Period {
    var allTimeouts: [Timeout] {
        var retval = [UUID:Timeout]()
        for kv in self.connection.state {
            if let rest = kv.key.dropping(parent: self.statePath) {
                if case let .id("Timeout", id: timeoutID) = rest.first {
                    retval[timeoutID] = Timeout(parent: self, timeoutID)
                }
            }
        }
        // and sort by wall time starts
        return retval.values.sorted { t1, t2 in
            (t1.walltimeStart ?? 0) < (t2.walltimeStart ?? 0)
        }
    }
    
    /// Calculate the walltime from a period time (where period time is elapsed period time, and NOT display period time)
    /// - Parameter elapsed: The elapsed period time
    /// - Returns: The wall time
    func wallTimeFrom(periodTime elapsed: PeriodTime) -> WallTime? {
        guard let start = walltimeStart else {
            return nil
        }
        // factor in the timeouts when the period clock was stopped
        var timeoutTotal = 0
        for timeout in allTimeouts {
            guard let pClock = timeout.periodClockElapsedEnd, let startW = timeout.walltimeStart, let endW = timeout.walltimeEnd else {
                continue
            }
            if elapsed > pClock {
                timeoutTotal += endW - startW
            } else {
                break // this was later, so we are done
            }
        }
        return start + elapsed + timeoutTotal
    }
}


public extension Jam where P == Period {
    /// Calculate the walltime from a jam time (where jam time is elasped since start of jam)
    /// - Parameter elapsed: The elapsed jam time
    /// - Returns: The wall time
    func wallTimeFrom(jamTime elapsed: JamTime) -> WallTime? {
        let period = self.parent
        guard let jamStart = self.periodClockElapsedStart, let jamWallTime = period.wallTimeFrom(periodTime: jamStart) else {
            return nil
        }
        return jamWallTime + elapsed
    }
}

public extension Team {
    var allBoxTrips: [BoxTrip<Team>] {
        var retval = [UUID:BoxTrip<Team>]()
        for kv in self.connection.state {
            if let rest = kv.key.dropping(parent: self.statePath) {
                if case let .id("BoxTrip", id: tripID) = rest.first {
                    retval[tripID] = BoxTrip(parent: self, tripID)
                }
            }
        }
        // and sort by wall time starts
        return retval.values.sorted { t1, t2 in
            (t1.walltimeStart ?? 0) < (t2.walltimeStart ?? 0)
        }
    }

}
