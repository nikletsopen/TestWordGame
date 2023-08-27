//
//  ContentView.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 25.08.2023.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    let store: StoreOf<WordPairsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Correct attempts: \(viewStore.correctAttemptsCount)")
                            .fontWeight(.bold)
                        Text("Wrong attempts: \(viewStore.wrongAttemptsCount)")
                            .fontWeight(.bold)
                    }
                }

                Spacer()

                VStack {
                    Text(viewStore.currentSource)
                        .font(.system(size: 36.0))
                        .padding()
                    Text(viewStore.currentTranslation)
                        .font(.system(size: 24.0))
                }

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        viewStore.send(.correctButtonTapped, animation: .linear)
                    } label: {
                        Text("Correct").bold()
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .clipShape(Capsule())

                    Spacer()

                    Button {
                        viewStore.send(.wrongButtonTapped, animation: .linear)
                    } label: {
                        Text("Wrong").bold()
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.pink)
                    .clipShape(Capsule())
                }
            }
            .padding()
            .onAppear{
                viewStore.send(.fetchTasks)
                viewStore.send(.startTimer)
            }
            .onChange(of: scenePhase, perform: { newPhase in
                if newPhase == .active && viewStore.shouldRestart {
                    viewStore.send(.restartGame)
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

