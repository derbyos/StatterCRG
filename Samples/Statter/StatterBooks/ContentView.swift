//
//  ContentView.swift
//  StatterBooks
//
//  Created by gandreas on 8/9/23.
//

import SwiftUI
import StatterCRG
import StatterCRGUI

struct ListTeam: View {
    @Stat var team: Team
    var body: some View {
        Table(team.skaters.allValues(), columns: {
            TableColumn("#") { skater in
                Text(skater.rosterNumber ?? "--")
            }
            TableColumn("Name") { skater in
                Text(skater.name ?? "--")
            }
        })
    }
}
struct ListPeriod: View {
    @Stat var period: Period
    struct PeriodJamAndSP : Identifiable, Hashable, Equatable {
        static func == (lhs: ListPeriod.PeriodJamAndSP, rhs: ListPeriod.PeriodJamAndSP) -> Bool {
            lhs.jam.id == rhs.jam.id && lhs.sp == rhs.sp
        }
        func hash(into hasher: inout Hasher) {
            jam.id.hash(into: &hasher)
            sp.hash(into: &hasher)
        }
        
        var id: Self { self }
        var jam: Jam<Period>
        var sp: Bool
    }
    var sortedJams: [PeriodJamAndSP] {
        guard let firstJam = period.firstJamNumber, let lastJam = period.currentJamNumber else {
            return []
        }
        return (firstJam ... lastJam).flatMap({
            if period.jam($0).starPass == true {
                return [PeriodJamAndSP(jam: period.jam($0), sp: false), PeriodJamAndSP(jam: period.jam($0), sp: true)]
            } else {
                return [PeriodJamAndSP(jam: period.jam($0), sp: false)]
            }
        })
    }
//    @TableColumnBuilder<PeriodJamAndSP, Never> func columns(for teamNum: Int) -> some TableColumnContent {
//        TableColumn("Jammer") { jamSP in
//            let tj = jamSP.jam.teamJam(teamNum)
//            if jamSP.sp == false {
//                Text(tj.id.description)
//            }
//        }
//    }
    func skaterNumber(id: UUID?) -> String {
        guard let id else { return "???" }
        if let skater = period.parent.teamOne.skater(id).rosterNumber {
            return skater
        }
        if let skater = period.parent.teamTwo.skater(id).rosterNumber {
            return skater
        }
        return "???"
    }
    @TableColumnBuilder<PeriodJamAndSP, Never> func lineupColumn(team: Int, pos: TeamJam<Period>.Position) -> some TableColumnContent<PeriodJamAndSP, Never> {
        TableColumn(pos.rawValue.capitalized) { jamSP in
            let tj = jamSP.jam.teamJam(team)
            HStack {
                if jamSP.sp == true {
                    if tj.starPass == true {
                        if let fielding = tj.fieldings[pos == .jammer ? .pivot : (pos == .pivot ? .jammer : pos)] {
                            Text(skaterNumber(id: fielding.skater))
                            Text(fielding.boxTripSymbolsAfterSP ?? "")
                        }
                    } else {
                        Text("-")
                    }
                } else {
                    if let fielding = tj.fieldings[pos] {
                        Text(skaterNumber(id: fielding.skater))
                        Text(fielding.boxTripSymbolsBeforeSP ?? "")
                    }
                }
            }
        }
    }
//    @TableColumnBuilder<PeriodJamAndSP, Never> func flag(team: Int, title: String, _ path: KeyPath<TeamJam<Period>, Bool?>) -> some TableColumnContent<PeriodJamAndSP, Never> {
//        TableColumn(title) { jamSP in
//            let tj = jamSP.jam.teamJam(team)
//            if jamSP.sp == true {
//                Text("")
//            } else {
//                if tj[keyPath: path] == true {
//                    Text("X")
//                } else {
//                    Text("")
//                }
//            }
//        }
//    }

    @TableColumnBuilder<PeriodJamAndSP, Never> func jamFlags(team: Int) -> some TableColumnContent<PeriodJamAndSP, Never> {
        TableColumn("") { jamSP in
            let tj = jamSP.jam.teamJam(team)
            if jamSP.sp == true {
                Text("")
            } else {
                HStack {
                    if tj.lost == true {
                        Text("Lo")
                    }
                    if tj.lead == true {
                        Text("Le")
                    }
                    if tj.calloff == true {
                        Text("Ca")
                    }
                    if tj.injury == true {
                        Text("Inj")
                    }
                    if tj.noInitial == true {
                        Text("Ni")
                    }
                }
            }
        }
    }

    @TableColumnBuilder<PeriodJamAndSP, Never> func scorePasses(team: Int) -> some TableColumnContent<PeriodJamAndSP, Never> {
        TableColumn("Passes") { jamSP in
            let tj = jamSP.jam.teamJam(team)
            if jamSP.sp == true {
                Text("")
            } else {
                HStack {
                    ForEach(1 ..< 9) {
                        let trip = tj.scoringTrip($0)
                        if let score = trip.score {
                            Text("\(score)")
                        }
                    }
                }
            }
        }
        TableColumn("Score") { jamSP in
            let tj = jamSP.jam.teamJam(team)
            if jamSP.sp == true {
                
            } else {
                HStack {
                    if let jamScore = tj.jamScore {
                        Text("\(jamScore)")
                    } else {
                        Text("-")
                    }
                    Spacer()
                    if let totalScore = tj.totalScore {
                        Text("\(totalScore)")
                    } else {
                        Text("0")
                    }
                }
            }
        }
    }
    var body: some View {
        Table(sortedJams, columns: {
            TableColumn("#") { jamSP in
                if jamSP.sp == true {
                    Text("*")
                } else {
                    Text("#\(jamSP.jam.number ?? 0)")
                }
            }
            Group {
//                flag(team: 1, title: "NP", \.)
                lineupColumn(team: 1, pos: .jammer)
                jamFlags(team: 1)
                lineupColumn(team: 1, pos: .pivot)
                lineupColumn(team: 1, pos: .blocker1)
                lineupColumn(team: 1, pos: .blocker2)
                lineupColumn(team: 1, pos: .blocker3)
                scorePasses(team: 1)
            }
            Group {
                lineupColumn(team: 2, pos: .jammer)
                jamFlags(team: 2)
                lineupColumn(team: 2, pos: .pivot)
                lineupColumn(team: 2, pos: .blocker1)
                lineupColumn(team: 2, pos: .blocker2)
                lineupColumn(team: 2, pos: .blocker3)
                scorePasses(team: 2)
            }
        })
    }
}
struct ListGame: View {
    @Stat var game: Game
    var body: some View {
        List {
            Section("Teams") {
                NavigationLink("Team 1") {
                    ListTeam(team: game.teamOne)
                }
                NavigationLink("Team 2") {
                    ListTeam(team: game.teamTwo)
                }
            }
            Section("Periods") {
                NavigationLink("Period 1") {
                    ListPeriod(period: game.period(1))
                }
                NavigationLink("Period 2") {
                    ListPeriod(period: game.period(2))
                }
            }
        }
    }
}
struct ContentView: View {
    @Binding var document: StatterBooksDocument
    struct DumpState : View {
        @EnvironmentObject var scoreboard: Connection
        @State var search: String = ""
        var body: some View {
            List {
                ForEach(scoreboard.state.enumerated().filter{
                    if search == "" {
                        return true
                    }
                    return $0.element.key.description.localizedCaseInsensitiveContains(search) || $0.element.value.description.localizedCaseInsensitiveContains(search)
                }, id:\.offset) {
                    let entry = $0.element
                    HStack {
                        Text("\(entry.key.description)")
                        Spacer()
                        Text("\(entry.value.description)")
                    }
                }
            }
        }
    }
    var body: some View {
        NavigationStack {
            List {
                Section("Games") {
                    ForEach(document.game.scoreBoard.games.keys().map{$0}, id: \.self) { gameID in
                        if let game = document.game.scoreBoard.games[gameID] {
                            NavigationLink(gameID.uuidString, destination: {
                                ListGame(game: game)
                            })
                        }
                    }
                }
            }
        }
        .environmentObject(document.game)
        DumpState()
            .environmentObject(document.game)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(StatterBooksDocument()))
    }
}
