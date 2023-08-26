//
//  ContentView.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 25.08.2023.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
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
                        .font(.system(size: 24.0))
                        .padding()
                    Text(viewStore.currentTranslation)
                }

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        viewStore.send(.correctButtonTapped)
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
                        viewStore.send(.wrongButtonTapped)
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
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(
                initialState: WordPairsFeature.State(),
                reducer: {
                    WordPairsFeature()
                })
        )
    }
}

