//
//  StatterBooksApp.swift
//  StatterBooks
//
//  Created by gandreas on 8/9/23.
//

import SwiftUI

@main
struct StatterBooksApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: StatterBooksDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
