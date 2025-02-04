//
//  MotionAlongPath.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI

struct MotionAlongPath: AnimatableModifier {
    var pct: CGFloat
    let path: Path

    var animatableData: CGFloat {
        get { pct }
        set { pct = newValue }
    }

    func body(content: Content) -> some View {
        let point = position(at: pct)
        return content.position(x: point.x, y: point.y)
    }

    func position(at percent: CGFloat) -> CGPoint {
        let trimmedPath = path.trimmedPath(from: 0, to: percent)
        return trimmedPath.currentPoint ?? .zero
    }
}
