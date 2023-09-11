//
//  ContentView.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 25.08.2023.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        // To start and stop outside of the screen bounds
        static let extraYPosition = 80.0
    }
    
    // MARK: - State
    
    @Environment(\.scenePhase) var scenePhase
    
    let store: StoreOf<WordPairsFeature>
    
    struct ViewState: Equatable {
        let currentSource: String
        let currentTranslation: String
        let correctAttemptsCount: Int
        let wrongAttemptsCount: Int
        let shouldRestart: Bool
        
        init(state: WordPairsFeature.State) {
            self.currentSource = state.currentSource
            self.currentTranslation = state.currentTranslation
            self.correctAttemptsCount = state.correctAttemptsCount
            self.wrongAttemptsCount = state.wrongAttemptsCount
            self.shouldRestart = state.shouldRestart
        }
    }
    
    @State private var translationPositionY: CGFloat = 0
    @State private var translationFontSize: CGFloat = 24.0
    
    // MARK: - Body
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            ZStack {
                GeometryReader { proxy in
                    Text(viewStore.currentTranslation)
                        .font(.system(size: translationFontSize))
                        .position(x: proxy.size.width / 2, y: translationPositionY)
                        .onChange(of: viewStore.currentTranslation) { newValue in
                            translationPositionY = -Constants.extraYPosition
                            translationFontSize = 24.0
                            
                            withAnimation(.easeIn(duration: Double(AppConstants.maxAttemptTime))) {
                                translationPositionY = proxy.size.height + Constants.extraYPosition
                                translationFontSize = 48.0
                            }
                        }
                        .animation(.easeIn(duration: 0.2), value: viewStore.currentTranslation)
                }
                
                VStack {
                    ResultsView(
                        correctAttemptsCount: viewStore.correctAttemptsCount,
                        wrongAttemptsCount: viewStore.wrongAttemptsCount)
                   
                    Spacer()
                    
                    Text(viewStore.currentSource)
                        .font(.system(size: 36.0))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 48)
                        .background(.cyan)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                        .animation(.easeIn(duration: 0.2), value: viewStore.currentSource)
                    
                    Spacer()
                    
                    AnswerButtonView(
                        correctButtonHandler: {viewStore.send(.correctButtonTapped)},
                        wrongButtonHandler: {viewStore.send(.wrongButtonTapped)})
                }
                .padding()
            }
            .onAppear{
                viewStore.send(.startGame)
            }
            .onChange(of: scenePhase, perform: { newPhase in
                if newPhase == .active && viewStore.shouldRestart {
                    viewStore.send(.startGame)
                }
            })
            .alert(store: self.store.scope(
                state: \.$resultsAlert,
                action: { .showResultsAlert($0)}))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let previewStore = Store(
            initialState: WordPairsFeature.State(),
            reducer: {
                WordPairsFeature()
            },
            withDependencies: {
                $0.continuousClock = TestClock()
            })
        ContentView(store: previewStore)
    }
}
