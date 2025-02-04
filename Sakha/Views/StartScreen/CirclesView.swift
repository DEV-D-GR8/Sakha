//
//  CirclesView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI

struct CirclesView: View {
    @Binding var circleExpansion: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 15)
                .scaleEffect(circleExpansion >= 3 ? 4 : 1)
                .opacity(circleExpansion >= 3 ? 0 : 1)
                .frame(width: 280, height: 280)
                .animation(.easeOut(duration: 0.5).delay(0.8), value: circleExpansion)

            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 22)
                .scaleEffect(circleExpansion >= 2 ? 3.5 : 1)
                .opacity(circleExpansion >= 2 ? 0 : 1)
                .frame(width: 239, height: 239)
                .animation(.easeOut(duration: 0.5).delay(0.9), value: circleExpansion)

            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 15)
                .scaleEffect(circleExpansion >= 1 ? 3 : 1)
                .opacity(circleExpansion >= 1 ? 0 : 1)
                .frame(width: 200, height: 200)
                .animation(.easeOut(duration: 0.5).delay(1), value: circleExpansion)
        }
    }
}
