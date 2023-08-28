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
    
    @State private var translationPositionY: CGFloat = 0
    @State private var translationFontSize: CGFloat = 24.0
   
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                GeometryReader { proxy in
                    Text(viewStore.currentTranslation)
                        .font(.system(size: translationFontSize))
                        .position(x: proxy.size.width / 2, y: translationPositionY)
                        .onChange(of: viewStore.currentTranslation) { newValue in
                            // Start above the screen
                            translationPositionY = -80
                            translationFontSize = 24.0
                            
                            // Add a short visual delay to sync better with timer 
                            withAnimation(.easeIn(duration: Double(AppConstants.maxAttemptTime) + 0.8)) {
                                // Finish bellow the screen
                                translationPositionY = proxy.size.height + 80
                                translationFontSize = 48.0
                            }
                        }
                        .animation(.easeIn(duration: 0.2), value: viewStore.currentTranslation)
                    
                }
                
                VStack {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            Text("Correct attempts: \(viewStore.correctAttemptsCount)")
                                .fontWeight(.bold)
                            Text("Wrong attempts: \(viewStore.wrongAttemptsCount)")
                                .fontWeight(.bold)
                        }
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                    }
                    
                    Spacer()
                    
                    Text(viewStore.currentSource)
                        .font(.system(size: 36.0))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 48)
                        .background(.cyan)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                        .animation(.easeIn(duration: 0.2), value: viewStore.currentSource)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button {
                            viewStore.send(.correctButtonTapped)
                        } label: {
                            Text("Correct").bold()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green)
                                .clipShape(RoundedRectangle(cornerRadius: 16.0))
                        }
                       
                        
                        Spacer()
                        
                        Button {
                            viewStore.send(.wrongButtonTapped)
                        } label: {
                            Text("Wrong").bold()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.pink)
                                .clipShape(RoundedRectangle(cornerRadius: 16.0))
                        }
                    }
                }
                .padding()
            }
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

