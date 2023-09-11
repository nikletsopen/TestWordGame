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
        var timer: TimerFeature.State?
        var shouldRestart = false
        @PresentationState var resultsAlert: AlertState<Action.Alert>?
    }
    
    enum Action: Equatable {
        case fetchTasks
        case correctButtonTapped
        case wrongButtonTapped
        case timer(TimerFeature.Action)
        case showNext
        case showResultsAlert(PresentationAction<Alert>)
        case endGame
        case closeApp
        case getReadyForRestart
        case startGame
        
        enum Alert {
            case restartGame
            case closeApp
        }
    }
    
    @Dependency(\.attemptTaskService) var attemptTaskService
    @Dependency(\.appClosingHelper) var appClosingHelper
    @Dependency(\.continuousClock) var clock
    
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
                    return processWrongAttempt(state: &state)
                }
            case .wrongButtonTapped:
                if state.attemptTasks[state.currentIndex].isCorrect {
                    return processWrongAttempt(state: &state)
                } else {
                    state.correctAttemptsCount += 1
                    return .send(.showNext)
                }
            case .showNext:
                state.timer?.timerTicksCount = 0
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
            case .showResultsAlert(.presented(.restartGame)):
                return .send(.startGame)
            case .showResultsAlert(.presented(.closeApp)):
                return .send(.closeApp)
            case .showResultsAlert(.dismiss):
                state.resultsAlert = nil
                return .none
            case .endGame:
                state.timer = nil
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
                
                return .none
            case .closeApp:
                appClosingHelper.close()
                
                // Wait for a fraction of second, so the user does not see when state gets cleaned
                return .run { send in
                    try await self.clock.sleep(for: .milliseconds(200))
                    await send(.getReadyForRestart)
                }
            case .getReadyForRestart:
                state = State()
                state.shouldRestart = true
                return .none
            case .startGame:
                state = State()
                state.timer = TimerFeature.State()
                return .concatenate(
                    .send(.fetchTasks),
                    .send(.timer(.startTimer))
                )
            case let .timer(.delegate(action)):
                switch action {
                case .timerTicked:
                    if state.timer?.timerTicksCount ?? 0 >= AppConstants.maxAttemptTime {
                        return processWrongAttempt(state: &state)
                    } else {
                        return .none
                    }
                }
            case .timer(_):
                return .none
            }
        }
        .ifLet(\.timer, action: /Action.timer) {
            TimerFeature(clock: _clock)
        }
    }
    
    private func processWrongAttempt(state: inout State) -> Effect<Action> {
        state.wrongAttemptsCount += 1
        if state.wrongAttemptsCount >= AppConstants.maxWrongAttempts {
            return .send(.endGame)
        } else {
            return .send(.showNext)
        }
    }
}
