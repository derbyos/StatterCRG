//
//  SwiftUIView.swift
//  
//
//  Created by gandreas on 7/26/23.
//

import SwiftUI

struct StackedBox<C:View>: View {
    var title: String
    var content: C
    public init(_ title: String, @ViewBuilder content: ()->C) {
        self.title = title
        self.content = content()
    }
    @Environment(\.formFactor) var formFactor
    var body: some View {
        #if os(macOS)
        GroupBox("Period \(period)") {
            content
        }
        #else
        VStack {
            Text(title)
                .formFactorFont(.subtitle)
                .frame(maxWidth: .infinity)
                .padding(.vertical, formFactor.lineWidth * 3)
                .background(Color.backgroundFill.opacity(0.5))
            content
                .padding()
        }
        .clipped()
        .border(Color.primary, width: formFactor.lineWidth)
        #endif
    }
}
