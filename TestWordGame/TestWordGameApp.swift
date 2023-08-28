//
//  TestWordGameApp.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 25.08.2023.
//

import ComposableArchitecture
import SwiftUI
import XCTestDynamicOverlay

@main
struct TestWordGameApp: App {
    var body: some Scene {
        WindowGroup {
            // Allow tests to run in the application target without actual application code interfering
            // See: - "Testing gotchas" https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/testing/#Testing-gotchas
            if !_XCTIsTesting {
                ContentView(
                    store: Store(
                        initialState: WordPairsFeature.State(),
                        reducer: {
                            WordPairsFeature()
                        })
                )
            }
        }
    }
}
