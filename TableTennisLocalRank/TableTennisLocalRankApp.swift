//
//  TableTennisLocalRankApp.swift
//  TableTennisLocalRank
//
//  Created by 杨挹 on 2/10/25.
//

import SwiftUI

@main
struct TableTennisLocalRankApp: App {
    init() {
        // Clear UserDefaults when the app starts
        UserDefaults.standard.removeObject(forKey: "playerList")
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
