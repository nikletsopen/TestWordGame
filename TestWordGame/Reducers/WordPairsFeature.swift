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
    }
    
    enum Action {
        case fetchTasks
        case correctButtonTapped
        case wrongButtonTapped
        case showNext
    }
    
    @Dependency(\.attemptTaskService) var attemptTaskService
    
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
                } else {
                    state.wrongAttemptsCount += 1
                }
                return .send(.showNext)
            case .wrongButtonTapped:
                if state.attemptTasks[state.currentIndex].isCorrect {
                    state.wrongAttemptsCount += 1
                } else {
                    state.correctAttemptsCount += 1
                }
                return .send(.showNext)
            case .showNext:
                state.currentIndex += 1
                
                // If reached the end, start all over again 
                guard state.currentIndex < state.attemptTasks.count else {
                    state.currentIndex = 0
                    return .send(.fetchTasks)
                }
                
                let task = state.attemptTasks[state.currentIndex]
                state.currentSource = task.source
                state.currentTranslation = task.translation
                return .none
            }
        }
    }
    
}
