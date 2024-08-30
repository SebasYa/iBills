//
//  iBillsApp.swift
//  iBills
//
//

import SwiftUI
import SwiftData

@main
struct iBillsApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [Invoice.self])
        }
    }
}
