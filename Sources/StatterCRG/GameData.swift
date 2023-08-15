//
//  File.swift
//  
//
//  Created by gandreas on 8/15/23.
//

import Foundation

// A bunch of "access by ID"
public extension Game {
    /// Find the skater by the UUID
    subscript(skater skaterID: UUID) -> Skater? {
        for team in [teamOne, teamTwo] {
            if let retval = team.skaters[skaterID] {
                return retval
            }
        }
        return nil
    }
    
    /// all skaters in the game, by ID
    var allSkaters: [UUID: (Team,Skater)] {
        var retval: [UUID: (Team,Skater)] = [:]
        for team in [teamOne, teamTwo] {
            for skater in team.skaters.allValues() {
                if let id = skater.skaterId {
                    retval[id] = (team,skater)
                }
            }
        }
        return retval
    }

    
    /// Find box trip by UUID
    subscript(boxTrip boxTripID: UUID) -> BoxTrip<Team>? {
        for team in [teamOne, teamTwo] {
            if let retval = team.allBoxTrips.first(where: {$0.boxTripId == boxTripID}) {
                return retval
            }
        }
        return nil
    }
    
    /// Find penalty by UUID
    subscript(penalty penaltyID: UUID) -> Penalty? {
        for team in [teamOne, teamTwo] {
            for skater in team.skaters.allValues() {
                for penalty in skater.penalties.allValues() {
                    if penalty.penaltyId == penaltyID {
                        return penalty
                    }
                }
            }
        }
        return nil
    }
    
    
    /// all penalties in the game, by ID
    var allPenalties: [UUID: Penalty] {
        var retval: [UUID: Penalty] = [:]
        for team in [teamOne, teamTwo] {
            for skater in team.skaters.allValues() {
                for penalty in skater.penalties.allValues() {
                    if let id = penalty.penaltyId {
                        retval[id] = penalty
                    }
                }
            }
        }
        return retval
    }
}
