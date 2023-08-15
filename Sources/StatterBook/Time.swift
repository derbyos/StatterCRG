//
//  File.swift
//  
//
//  Created by gandreas on 8/14/23.
//

import Foundation
import StatterCRG

/// An event in the game with a time stamp
public struct TimedEvent {
    /// When does this event happen (in wall time)
    public var time: WallTime
    public enum Event {
        case periodStart(Period)
        case periodEnd(Period)
        case jamStart(Jam<Period>)
        case jamEnd(Jam<Period>)
        case timeoutStart(Timeout)
        case timeoutEnd(Timeout)
        case scoringTripStart(ScoringTrip<TeamJam<Period>>)
        case scoringTripEnd(ScoringTrip<TeamJam<Period>>)
        case boxTripStart(BoxTrip<Team>)
        case boxTripEnd(BoxTrip<Team>)
    }
    /// What is the event
    public var event: Event
}

public extension Game {
    // Gather
    var timedEvents: [TimedEvent] {
        var retval = [TimedEvent]()
        for periodNum in 1 ... 2 {
            let period = self.period(periodNum)
            if let time = period.walltimeStart {
                retval.append(.init(time: time, event: .periodEnd(period)))
            }
            if let time = period.walltimeEnd {
                retval.append(.init(time: time, event: .periodEnd(period)))
            }
            for timeout in period.allTimeouts {
                if let time = timeout.walltimeStart {
                    retval.append(.init(time: time, event: .timeoutStart(timeout)))
                }
                if let time = timeout.walltimeEnd {
                    retval.append(.init(time: time, event: .timeoutEnd(timeout)))
                }
            }
            for jamNum in 1..<99 {
                let jam = period.jam(jamNum)
                guard let jtime = jam.walltimeStart else {
                    break
                }
                retval.append(.init(time: jtime, event: .jamStart(jam)))
                if let end = jam.walltimeEnd {
                    retval.append(.init(time: end, event: .jamEnd(jam)))
                }
                for teamJam in [jam.teamJam(1), jam.teamJam(2)] {
                    for tripNum in 1...20 {
                        let trip = teamJam.scoringTrip(tripNum)
                        guard let tstart = trip.jamClockStart, let tend = trip.jamClockEnd else {
                            break
                        }
                        retval.append(.init(time: tstart + jtime, event: .scoringTripStart(trip)))
                        retval.append(.init(time: tend + jtime, event: .scoringTripEnd(trip)))
                    }
                }
            }
        }
        for team in [self.teamOne, self.teamTwo] {
            for trip in team.allBoxTrips {
                guard let tstart = trip.walltimeStart, let tend = trip.walltimeEnd else {
                    break
                }
                retval.append(.init(time: tstart, event: .boxTripStart(trip)))
                retval.append(.init(time: tend, event: .boxTripStart(trip)))
            }
        }
        retval.sort { e1, e2 in
            e1.time < e2.time
        }
        return retval
    }
}
