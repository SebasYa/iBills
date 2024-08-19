//
//  iBillsApp.swift
//  iBills
//
//  Created by Sebastian Yanni on 05/08/2024.
//

import SwiftUI
import SwiftData

@main
struct iBillsApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [Invoice.self, Receipt.self])
        }
    }
}
