//
//  WordPairsFeature.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 26.08.2023.
//

import Foundation
import ComposableArchitecture

struct WordPairsFeature: Reducer {
    struct State: Equatable {
        var attemptTasks = [AttemptTask]()
        var currentIndex = 0
        var currentSource = ""
        var currentTranslation = ""
        var correctAttemptsCount = 0
        var wrongAttemptsCount = 0
        var timerTicksCount = 0
        var shouldRestart = false
    }
    
    enum Action {
        case fetchTasks
        case correctButtonTapped
        case wrongButtonTapped
        case processWrongAttempt
        case showNext
        case startTimer
        case timerTicked
        case stopTimer
        case endGame
        case getReadyForRestart
        case restartGame
    }
    
    private enum CancelId {
        case timer
    }
    
    private enum Constants {
        static let maxAttemptTime = 5
        static let maxWrongAttempts = 3
        static let maxAttempts = 15
    }
    
    @Dependency(\.attemptTaskService) var attemptTaskService
    @Dependency(\.continuousClock) var clock
    @Dependency(\.appClosingHelper) var appClosingHelper
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchTasks:
                let tasks = attemptTaskService.fetch()
                state.attemptTasks = tasks
                state.currentSource = tasks[0].source
                state.currentTranslation = tasks[0].translation
                return .none
            case .correctButtonTapped:
                if state.attemptTasks[state.currentIndex].isCorrect {
                    state.correctAttemptsCount += 1
                    return .send(.showNext)
                } else {
                    return .concatenate([
                        .send(.processWrongAttempt),
                        .send(.showNext)
                    ])
                }
            case .wrongButtonTapped:
                if state.attemptTasks[state.currentIndex].isCorrect {
                    return .concatenate([
                        .send(.processWrongAttempt),
                        .send(.showNext)
                    ])
                } else {
                    state.correctAttemptsCount += 1
                    return .send(.showNext)
                }
            case .showNext:
                state.currentIndex += 1
                
                // If reached the end, start all over again 
                guard state.currentIndex < state.attemptTasks.count else {
                    state.currentIndex = 0
                    return .send(.fetchTasks)
                }
                
                guard state.currentIndex < Constants.maxAttempts else {
                    return .send(.endGame)
                }
                
                let task = state.attemptTasks[state.currentIndex]
                state.currentSource = task.source
                state.currentTranslation = task.translation
                return .none
            case .startTimer:
                return .run { send in
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.timerTicked)
                    }
                }
                .cancellable(id: CancelId.timer)
            case .timerTicked:
                state.timerTicksCount += 1
                if state.timerTicksCount > Constants.maxAttemptTime {
                    state.timerTicksCount = 0 
                    return .send(.processWrongAttempt)
                } else {
                    return .none
                }
            case .stopTimer:
                return .cancel(id: CancelId.timer)
            case .processWrongAttempt:
                state.wrongAttemptsCount += 1
                if state.wrongAttemptsCount >= Constants.maxWrongAttempts {
                    return .send(.endGame)
                } else {
                    return .none
                }
            case .endGame:
                appClosingHelper.close()
                
                // Wait for a fraction of second, so the user does not see when state gets cleaned
                return .run { send in
                    try await self.clock.sleep(for: .milliseconds(200))
                    await send(.stopTimer)
                    await send(.getReadyForRestart)
                }
            case .getReadyForRestart:
                state = State()
                state.shouldRestart = true
                return .none
            case .restartGame:
                state = State()
                return .concatenate([
                    .send(.fetchTasks),
                    .send(.startTimer)
                ])
            }
        }
    }
}
