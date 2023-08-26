//
//  AppClosingHelper.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 26.08.2023.
//

import UIKit
import ComposableArchitecture

struct AppClosingHelper {
    var close: () -> ()
}

extension AppClosingHelper: DependencyKey {
    static let liveValue = Self {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }
}

extension DependencyValues {
    var appClosingHelper: AppClosingHelper {
        get { self[AppClosingHelper.self] }
        set { self[AppClosingHelper.self] = newValue }
    }
}



