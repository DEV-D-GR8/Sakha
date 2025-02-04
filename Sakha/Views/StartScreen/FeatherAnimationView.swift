//
//  FeatherAnimationView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI

struct FeatherAnimationView: View {
    @State private var pct: CGFloat = 0.0
    @State private var featherOpacity: Double = 0.0
    @State private var showText: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let centerPoint = CGPoint(x: size.width / 2, y: size.height / 2.3)
            let path = createClockwiseFeatherPath(center: centerPoint, imageSize: CGSize(width: 250, height: 250))

            ZStack {
                Image("feather")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .opacity(featherOpacity)
                    .rotationEffect(.degrees(pct * 180), anchor: .center)
                    .modifier(MotionAlongPath(pct: pct, path: path))

                if showText {
                    Text("Sakha")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.black)
                        .opacity(1.0)
                        .position(x: size.width / 2, y: centerPoint.y - 210)
                        .transition(.opacity)
                }
            }
            .onAppear {
                startAnimation()
            }
        }
    }

    func createClockwiseFeatherPath(center: CGPoint, imageSize: CGSize) -> Path {
        var path = Path()
        let startPoint = CGPoint(x: center.x, y: center.y - imageSize.height / 4)
        path.move(to: startPoint)

        path.addCurve(
            to: CGPoint(x: center.x, y: center.y - imageSize.height / 2 - 130),
            control1: CGPoint(x: center.x + imageSize.width * 1.8, y: center.y + imageSize.height + 100),
            control2: CGPoint(x: center.x - imageSize.width * 1.8, y: center.y + imageSize.height + 100)
        )

        return path
    }

    func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(Animation.easeIn(duration: 0.3)) {
                featherOpacity = 1.0
            }
        }

        let totalDuration: Double = 5.0

        withAnimation(Animation.easeInOut(duration: totalDuration)) {
            pct = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            withAnimation(Animation.easeOut(duration: 0.5)) {
                featherOpacity = 1.0
            }
            withAnimation(Animation.easeIn(duration: 1.0)) {
                showText = true
            }
        }
    }
}
