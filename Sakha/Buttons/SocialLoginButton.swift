//
//  SocialLoginButton.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI

struct SocialLoginButton: View {
    var image: Image
    var text: Text
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                image
                    .padding(.horizontal)
                Spacer()
                text
                    .font(.title2)
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(50)
            .shadow(color: Color.black.opacity(0.08), radius: 60, x: 0, y: 16)
        }
    }
}
