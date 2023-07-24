//
//  SwiftUIView.swift
//  
//
//  Created by gandreas on 7/24/23.
//

import SwiftUI

@ViewBuilder
func FlipGroup<V1: View, V2: View>(if value: Bool,
                @ViewBuilder _ content: @escaping () -> TupleView<(V1, V2)>) -> some View {
    let pair = content()
    if value {
        TupleView((pair.value.1, pair.value.0))
    } else {
        TupleView((pair.value.0, pair.value.1))
    }
}
@ViewBuilder
func FlipGroup<V1: View, V2: View, V3: View>(if value: Bool,
                @ViewBuilder _ content: @escaping () -> TupleView<(V1, V2, V3)>) -> some View {
    let pair = content()
    if value {
        TupleView((pair.value.2, pair.value.1, pair.value.0))
    } else {
        TupleView((pair.value.0, pair.value.1, pair.value.2))
    }
}
@ViewBuilder
func FlipGroup<V1: View, V2: View, V3: View, V4: View>(if value: Bool,
                @ViewBuilder _ content: @escaping () -> TupleView<(V1, V2, V3, V4)>) -> some View {
    let pair = content()
    if value {
        TupleView((pair.value.3, pair.value.2, pair.value.1, pair.value.0))
    } else {
        TupleView((pair.value.0, pair.value.1, pair.value.2, pair.value.3))
    }
}
@ViewBuilder
func FlipGroup<V1: View, V2: View, V3: View, V4: View, V5: View>(if value: Bool,
                @ViewBuilder _ content: @escaping () -> TupleView<(V1, V2, V3, V4, V5)>) -> some View {
    let pair = content()
    if value {
        TupleView((pair.value.4, pair.value.3, pair.value.2, pair.value.1, pair.value.0))
    } else {
        TupleView((pair.value.0, pair.value.1, pair.value.2, pair.value.3, pair.value.4))
    }
}

