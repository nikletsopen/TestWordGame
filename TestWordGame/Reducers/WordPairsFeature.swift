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
        @PresentationState var resultsAlert: AlertState<Action.Alert>?
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
        case showResultsAlert(PresentationAction<Alert>)
        case endGame
        case closeApp
        case getReadyForRestart
        case restartGame
        
        enum Alert {
            case restartGame
            case closeApp
        }
    }
    
    private enum CancelId {
        case timer
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
                    return .send(.processWrongAttempt)
                }
            case .wrongButtonTapped:
                if state.attemptTasks[state.currentIndex].isCorrect {
                    return .send(.processWrongAttempt)
                } else {
                    state.correctAttemptsCount += 1
                    return .send(.showNext)
                }
            case .showNext:
                state.timerTicksCount = 0
                state.currentIndex += 1
                
                // If reached the end, start all over again 
                guard state.currentIndex < state.attemptTasks.count else {
                    state.currentIndex = 0
                    return .send(.fetchTasks)
                }
                
                guard state.currentIndex < AppConstants.maxAttempts else {
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
                if state.timerTicksCount > AppConstants.maxAttemptTime {
                    return .send(.processWrongAttempt)
                } else {
                    return .none
                }
            case .stopTimer:
                return .cancel(id: CancelId.timer)
            case .processWrongAttempt:
                state.wrongAttemptsCount += 1
                if state.wrongAttemptsCount >= AppConstants.maxWrongAttempts {
                    return .send(.endGame)
                } else {
                    return .send(.showNext)
                }
            case .showResultsAlert(.presented(.restartGame)):
                return .send(.restartGame)
            case .showResultsAlert(.presented(.closeApp)):
                return .send(.closeApp)
            case .showResultsAlert(.dismiss):
                state.resultsAlert = nil
                return .none
            case .endGame:
                let correctAttemptsCount = state.correctAttemptsCount
                let wrongAttemptsCount = state.wrongAttemptsCount
                
                state.resultsAlert = AlertState {
                    TextState("Game over")
                } actions: {
                    ButtonState(
                        role: .none, action: .closeApp
                    ) {
                        TextState("Close App")
                    }
                    
                    ButtonState(
                        role: .cancel, action: .restartGame
                    ) {
                        TextState("Try Again")
                    }
                } message: {
                    TextState(
                        """
                        Want to try again? You current result:
                        \(correctAttemptsCount) correct, \(wrongAttemptsCount) wrong.
                        """
                    )
                }
                
                return .send(.stopTimer)
            case .closeApp:
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
