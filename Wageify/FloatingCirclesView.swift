//
//  SphereSceneView.swift
//  Wageify
//
//  Created by Carter Hammond on 1/29/25.
//

import SwiftUI

struct FloatingCirclesView: View {
    private let circleCount = 4 // ✅ Increased to 4 circles
    @State private var offsets: [CGSize] = Array(repeating: .zero, count: 4) // ✅ Initial positions
    @State private var sizes: [CGFloat] = (0..<4).map { _ in CGFloat.random(in: 300...500) } // ✅ Large sizes

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            // 🎨 Floating Circles
            ForEach(0..<circleCount, id: \.self) { index in
                Circle()
                    .fill(Color("AccentColor").opacity(0.3)) // ✅ AccentColor with transparency
                    .frame(width: sizes[index], height: sizes[index]) // ✅ Bigger circles
                    .offset(offsets[index])
                    .onAppear {
                        animateCircle(index)
                    }
            }
        }
    }

    // 🔄 **Floating Animation with Wider Spread**
    private func animateCircle(_ index: Int) {
        let duration = Double.random(in: 15...25) // ✅ Slow, premium movement
        let xRange: CGFloat = CGFloat.random(in: 600...1100) // ✅ Extra-wide spread
        let yRange: CGFloat = CGFloat.random(in: 600...1100)

        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            offsets[index] = CGSize(
                width: CGFloat.random(in: -xRange...xRange),
                height: CGFloat.random(in: -yRange...yRange)
            )
        }
    }
}

#Preview {
    FloatingCirclesView()
}


