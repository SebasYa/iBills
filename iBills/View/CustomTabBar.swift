//
//  CustomTabBar.swift
//  iBills
//
//  Created by Sebastian Yanni on 27/08/2024.
//

import SwiftUI

struct CustomTabBar: View {
    @State private var activeTab: TabModel = .home
    var body: some View {
        if #available(iOS 18, *) {
            TabView(selection: $activeTab) {
                Tab.init(value: .home) {
                    Text("Home")
                }
            }
        }
    }
}

#Preview {
    CustomTabBar()
}
