//
//  ScrollBottomSpacer.swift
//  iBills
//
//  Created by Sebastian Yanni on 04/04/2026.
//

import SwiftUI

private struct FloatingBottomInsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var floatingBottomInset: CGFloat {
        get { self[FloatingBottomInsetKey.self] }
        set { self[FloatingBottomInsetKey.self] = newValue }
    }
}

struct FloatingBottomInsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ScrollBottomSpacer: View {
    @Environment(\.floatingBottomInset) private var floatingBottomInset
    private let extraSpacing: CGFloat

    init(extraSpacing: CGFloat = 5) {
        self.extraSpacing = extraSpacing
    }

    var body: some View {
        Color.clear
            .frame(height: max(0, floatingBottomInset + extraSpacing))
            .accessibilityHidden(true)
    }
}

#Preview {
    ScrollBottomSpacer()
}
