//
//  TestWordGameApp.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 25.08.2023.
//

import ComposableArchitecture
import SwiftUI

@main
struct TestWordGameApp: App {
    var body: some Scene {
        WindowGroup {
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
