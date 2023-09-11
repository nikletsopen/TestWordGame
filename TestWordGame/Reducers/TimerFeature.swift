//
//  TimerFeature.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 11.09.2023.
//

import Foundation
import ComposableArchitecture

struct TimerFeature: Reducer {
    struct State: Equatable {
        var timerTicksCount = 0
    }
    
    enum Action: Equatable {
        case startTimer
        case stopTimer
        case delegate(Delegate)
        
        enum Delegate {
            case timerTicked
        }
    }
    
    private enum CancelId {
        case timer
    }
    
    @Dependency(\.continuousClock) var clock
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startTimer:
                return .run { send in
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.delegate(.timerTicked))
                    }
                }
                .cancellable(id: CancelId.timer)
            case .delegate(.timerTicked):
                state.timerTicksCount += 1
                return .none
            case .stopTimer:
                return .cancel(id: CancelId.timer)
            }
        }
    }
}
