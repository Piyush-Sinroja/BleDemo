//
//  BleDemoApp.swift
//  BleDemo
//
//  Created by Piyush Sinroja on 06/03/24.
//

import SwiftUI

@main
struct BleDemoApp: App {

    @StateObject private var bleManager = BLEManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
        }
    }
}
