//
//  TestWordGameTests.swift
//  TestWordGameTests
//
//  Created by Nikita Timonin on 25.08.2023.
//

import ComposableArchitecture
import XCTest
@testable import TestWordGame

@MainActor
final class TestWordGameTests: XCTestCase {

    func testFetchAttempts() async {
        let store = TestStore(initialState: WordPairsFeature.State()) {
            WordPairsFeature()
        } withDependencies: {
            $0.attemptTaskService.fetch = {
                testTasks
            }
            $0.continuousClock = UnimplementedClock()
        }
        
        await store.send(.fetchTasks) {
            $0.attemptTasks = testTasks
            $0.currentSource = testTasks[0].source
            $0.currentTranslation = testTasks[0].translation
        }
    }
    
    func testTrueCorrectAnswer() async {
        let store = TestStore(initialState: WordPairsFeature.State()) {
            WordPairsFeature()
        } withDependencies: {
            $0.attemptTaskService.fetch = {
                testTasks
            }
            $0.continuousClock = UnimplementedClock()
        }
        
        await store.send(.fetchTasks) {
            $0.attemptTasks = testTasks
            $0.currentSource = testTasks[0].source
            $0.currentTranslation = testTasks[0].translation
        }
        
        await store.send(.correctButtonTapped) {
            $0.correctAttemptsCount = 1
        }

        await store.receive(.showNext) {
            $0.timerTicksCount = 0
            $0.currentIndex = 1
            $0.currentSource = testTasks[1].source
            $0.currentTranslation = testTasks[1].translation
        }
    }
    
    func testFalseWrongAsnwer() async {
        let store = TestStore(initialState: WordPairsFeature.State()) {
            WordPairsFeature()
        } withDependencies: {
            $0.attemptTaskService.fetch = {
                testTasks
            }
            $0.continuousClock = UnimplementedClock()
        }
        
        await store.send(.fetchTasks) {
            $0.attemptTasks = testTasks
            $0.currentSource = testTasks[0].source
            $0.currentTranslation = testTasks[0].translation
        }
        
        await store.send(.wrongButtonTapped) {
            $0.wrongAttemptsCount = 1
        }
        
        await store.receive(.showNext) {
            $0.timerTicksCount = 0
            $0.currentIndex = 1
            $0.currentSource = testTasks[1].source
            $0.currentTranslation = testTasks[1].translation
        }
    }
    
    func testCorrectWrongAsnwer() async {
        let testTasks = [
            AttemptTask(source: "class", translation: "vacaciones", isCorrect: false),
            AttemptTask(source: "primary school", translation: "escuela primaria", isCorrect: true),
        ]
        let store = TestStore(initialState: WordPairsFeature.State()) {
            WordPairsFeature()
        } withDependencies: {
            $0.attemptTaskService.fetch = {
               testTasks
            }
            $0.continuousClock = UnimplementedClock()
        }
        
        await store.send(.fetchTasks) {
            $0.attemptTasks = testTasks
            $0.currentSource = testTasks[0].source
            $0.currentTranslation = testTasks[0].translation
        }
        
        await store.send(.wrongButtonTapped) {
            $0.correctAttemptsCount = 1
        }
        
        
        await store.receive(.showNext) {
            $0.timerTicksCount = 0
            $0.currentIndex = 1
            $0.currentSource = testTasks[1].source
            $0.currentTranslation = testTasks[1].translation
        }
    }
    
    func testWrongAttemptsGameOver() async {
        let store = TestStore(initialState: WordPairsFeature.State()) {
            WordPairsFeature()
        } withDependencies: {
            $0.attemptTaskService.fetch = {
                testTasks
            }
            $0.continuousClock = UnimplementedClock()
        }
        
        await store.send(.fetchTasks) {
            $0.attemptTasks = testTasks
            $0.currentSource = testTasks[0].source
            $0.currentTranslation = testTasks[0].translation
        }
        
        await store.send(.wrongButtonTapped) {
            $0.wrongAttemptsCount = 1
        }
        
        await store.receive(.showNext) {
            $0.timerTicksCount = 0
            $0.currentIndex = 1
            $0.currentSource = testTasks[1].source
            $0.currentTranslation = testTasks[1].translation
        }
        
        await store.send(.wrongButtonTapped) {
            $0.wrongAttemptsCount = 2
        }
        
        await store.receive(.showNext) {
            $0.timerTicksCount = 0
            $0.currentIndex = 2
            $0.currentSource = testTasks[2].source
            $0.currentTranslation = testTasks[2].translation
        }
        
        await store.send(.wrongButtonTapped) {
            $0.wrongAttemptsCount = 3
        }
        
        await store.receive(.endGame) {
            let correctAttemptsCount = $0.correctAttemptsCount
            let wrongAttemptsCount = $0.wrongAttemptsCount
            
            $0.resultsAlert = AlertState {
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
        }
        
        await store.receive(.stopTimer)
    }
    
    func testAttemptTimeout() async {
        let clock = TestClock()
        let store = TestStore(initialState: WordPairsFeature.State()) {
            WordPairsFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.attemptTaskService.fetch = {
                testTasks
            }
        }
        
        await store.send(.fetchTasks) {
            $0.attemptTasks = testTasks
            $0.currentSource = testTasks[0].source
            $0.currentTranslation = testTasks[0].translation
        }
        
        await store.send(.startTimer)
        
        await clock.advance(by: .seconds(1))
 
        await store.receive(.timerTicked) {
            $0.timerTicksCount = 1
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.timerTicksCount = 2
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.timerTicksCount = 3
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.timerTicksCount = 4
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.timerTicksCount = 5
            $0.wrongAttemptsCount = 1
        }

        await store.receive(.showNext) {
            $0.timerTicksCount = 0
            $0.currentIndex = 1
            $0.currentSource = testTasks[1].source
            $0.currentTranslation = testTasks[1].translation
        }
        
        await store.send(.stopTimer)
    }
    
    func testRestart() async {
        let store = TestStore(initialState: WordPairsFeature.State()) {
            WordPairsFeature()
        } withDependencies: {
            $0.attemptTaskService.fetch = {
                testTasks
            }
            $0.continuousClock = TestClock() 
        }
        
        await store.send(.fetchTasks) {
            $0.attemptTasks = testTasks
            $0.currentSource = testTasks[0].source
            $0.currentTranslation = testTasks[0].translation
        }
        
        await store.send(.restartGame) {
            $0.attemptTasks = []
            $0.currentSource = ""
            $0.currentTranslation = ""
        }
        
        await store.receive(.fetchTasks) {
            $0.attemptTasks = testTasks
            $0.currentSource = testTasks[0].source
            $0.currentTranslation = testTasks[0].translation
        }
        
        await store.receive(.startTimer)
        await store.send(.stopTimer)
    }
    
}

private let testTasks = [
    AttemptTask(source: "primary school", translation: "escuela primaria", isCorrect: true),
    AttemptTask(source: "exercise book", translation: "cuaderno", isCorrect: true),
    AttemptTask(source: "quiet", translation: "quieto", isCorrect: true),
    AttemptTask(source: "primary school", translation: "escuela primaria", isCorrect: true),
    AttemptTask(source: "class", translation: "vacaciones", isCorrect: false),
]
