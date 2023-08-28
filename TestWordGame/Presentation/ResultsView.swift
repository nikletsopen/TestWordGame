//
//  ResultsView.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 28.08.2023.
//

import SwiftUI

struct ResultsView: View {
    let correctAttemptsCount: Int
    let wrongAttemptsCount: Int
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("Correct attempts: \(correctAttemptsCount)")
                    .fontWeight(.bold)
                Text("Wrong attempts: \(wrongAttemptsCount)")
                    .fontWeight(.bold)
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16.0))
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(
            correctAttemptsCount: 5,
            wrongAttemptsCount: 3)
    }
}
