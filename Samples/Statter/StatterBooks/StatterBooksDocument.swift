//
//  StatterBooksDocument.swift
//  StatterBooks
//
//  Created by gandreas on 8/9/23.
//

import SwiftUI
import UniformTypeIdentifiers
import StatterCRG
import StatterBook

extension UTType {
    static var savedGameJSON: UTType {
        UTType(importedAs: "com.gandreas.savedcrggame")
    }
}

struct StatterBooksDocument: FileDocument {
    var game: Connection

    init() {
        game = Connection.blankGameData()
    }

    static var readableContentTypes: [UTType] { [.savedGameJSON] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let connection = try Connection(game: data)
        game = connection
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try game.saveState()
        return .init(regularFileWithContents: data)
    }
}


extension StatterBooksDocument {
    /// A preview game json in the preview content
    static var preview : StatterBooksDocument {
        var retval = StatterBooksDocument()
        // downloading the stats some places adds the .txt, fwiw
//        let url = Bundle.allBundles.compactMap({$0.url(forResource: "STATS-2023-04-30_NSRDSupernovas_vs_DRDAllstars_1", withExtension: "json")}).first!
        let url = URL(filePath: "/Users/gandreas/Sources/StatterCRG/Samples/Statter/StatterBooks/Preview Content/STATS-2023-04-30_NSRDSupernovas_vs_DRDAllstars_1.json")
        let data = try! Data(contentsOf: url)
        let game = try! Connection(game: data)
        retval.game = game
        return retval
        
    }
}
