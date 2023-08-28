//
//  AnswerButtonView.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 28.08.2023.
//

import SwiftUI

struct AnswerButtonView: View {
    let correctButtonHandler: () -> ()
    let wrongButtonHandler: () -> ()
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                correctButtonHandler()
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
                wrongButtonHandler()
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
}

struct AnswerButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AnswerButtonView(
            correctButtonHandler: {},
            wrongButtonHandler: {})
    }
}
