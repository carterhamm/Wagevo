import SwiftUI
import CoreHaptics

struct CashOutView: View {
    // MARK: - States
    @State private var isPressing = false
    @State private var completedHold = false
    
    @State private var circleScale: CGFloat = 0.0
    
    // UI states
    @State private var showPaymentMessage = false
    @State private var showConfetti = false
    @State private var showNoUnpaidShifts = false
    
    @State private var promptText = "Tap and hold"
    @State private var symbolName = "hand.tap"  // Switches to "hand.tap.fill" when pressing

    // Hold timer
    @State private var holdWorkItem: DispatchWorkItem? = nil
    
    // Haptic Engine
    @State private var engine: CHHapticEngine?
    @State private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    
    // Hold duration
    private let holdDuration: TimeInterval = 2.5
    
    var body: some View {
        ZStack {
            // MARK: - Background / Growing Circle
            if !showNoUnpaidShifts {
                GeometryReader { geo in
                    Circle()
                        .fill(Color.accentColor)
                        // Large enough to fill the screen when scale = 1
                        .frame(width: max(geo.size.width, geo.size.height) * 1.4,
                               height: max(geo.size.width, geo.size.height) * 1.4)
                        .scaleEffect(circleScale)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2 - 50)
                }
                .ignoresSafeArea()
            }
            
            // MARK: - Main Content (Pre‑Cash Out)
            if !showPaymentMessage && !showNoUnpaidShifts {
                VStack {
                    Spacer()
                    
                    // Dynamic text color switches to white once circle grows enough
                    let dynamicColor = circleScale > 0.5 ? Color.white : Color.accentColor
                    
                    Text("$625.42")
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(dynamicColor)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: symbolName)
                        Text(promptText)
                    }
                    .font(.headline)
                    .foregroundColor(dynamicColor)
                    .padding(.bottom, 50)
                }
                .padding()
            }
            
            // MARK: - Success Message (Animated)
            if showPaymentMessage && !showNoUnpaidShifts {
                VStack(spacing: 20) {
                    Text("You got paid!")
                        .font(.system(size: 50, weight: .heavy))
                        .foregroundColor(.white)
                    Text("$625.42")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                // Animate from above
                .transition(.move(edge: .top))
                .animation(.spring(), value: showPaymentMessage)
                .zIndex(1)
            }
            
            // MARK: - Confetti
            if showConfetti && !showNoUnpaidShifts {
                // Pass the screen size via UIScreen for simplicity
                ConfettiView(geoSize: UIScreen.main.bounds.size)
                    .ignoresSafeArea()
            }
            
            // MARK: - No Unpaid Shifts
            if showNoUnpaidShifts {
                Text("No Unpaid Shifts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .transition(.opacity)
            }
        }
        // Ensure the gesture covers the entire area
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    // Begin only if not already pressing and not in a final state
                    if !isPressing && !showPaymentMessage && !showNoUnpaidShifts {
                        isPressing = true
                        completedHold = false
                        
                        // Reset states
                        circleScale = 0.0
                        promptText = "Tap and hold"
                        symbolName = "hand.tap.fill"
                        showConfetti = false
                        showPaymentMessage = false
                        
                        // Animate circle growth over 2.5s
                        withAnimation(.linear(duration: holdDuration)) {
                            circleScale = 1.0
                        }
                        
                        // Begin continuous ramping haptic
                        playRampingHaptic()
                        
                        // After holdDuration, if still pressing, update prompt
                        let workItem = DispatchWorkItem {
                            if isPressing {
                                completedHold = true
                                promptText = "Release to cash out"
                                playDoubleHaptic()  // Play double tap haptic right after windup haptic
                            }
                        }
                        holdWorkItem = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration, execute: workItem)
                    }
                }
                .onEnded { _ in
                    // Cancel any pending hold work item
                    holdWorkItem?.cancel()
                    
                    // Stop the ramping haptic
                    stopContinuousHaptic()
                    
                    if completedHold {
                        // Successful full hold: double tap haptic already played in onChanged
                        // Show success message and confetti
                        withAnimation {
                            showConfetti = true
                            showPaymentMessage = true
                        }
                        
                        // After 2 seconds, remove circle & success UI and show final text
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showConfetti = false
                                showPaymentMessage = false
                                showNoUnpaidShifts = true
                            }
                        }
                    } else {
                        // Incomplete hold: animate circle shrinking
                        withAnimation {
                            circleScale = 0.0
                        }
                    }
                    
                    // Reset gesture state for future attempts
                    isPressing = false
                    promptText = "Tap and hold"
                    symbolName = "hand.tap"
                }
        )
        .onAppear {
            prepareHapticEngine()
        }
    }
}

// MARK: - Haptics
extension CashOutView {
    private func prepareHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error starting haptic engine: \(error.localizedDescription)")
        }
    }
    
    private func playRampingHaptic() {
        guard let engine = engine,
              CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let duration = holdDuration
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            ],
            relativeTime: 0,
            duration: duration
        )
        
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0),
                CHHapticParameterCurve.ControlPoint(relativeTime: duration, value: 1)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [intensityCurve])
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: 0)
        } catch {
            print("Failed to play ramping haptic: \(error.localizedDescription)")
        }
    }
    
    private func stopContinuousHaptic() {
        do {
            try continuousPlayer?.stop(atTime: 0)
        } catch {
            print("Failed to stop continuous haptic: \(error.localizedDescription)")
        }
    }
    
    private func playDoubleHaptic() {
        guard let engine = engine,
              CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        // First strong, sharp tap
        let firstTap = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0
        )
        
        // Second HEAVY and STRONG tap
        let secondTapTransient = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0.3 // Starts 0.3 seconds after the first tap
        )
        
        let secondTapHeavy = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5) // Lower sharpness for a "heavier" feel
            ],
            relativeTime: 0.3, // Overlaps with transient
            duration: 0.08 // Short, punchy duration for weight without lingering
        )
        
        let secondTapReinforce = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ],
            relativeTime: 0.32 // Quick follow-up for extra oomph
        )
        
        do {
            let pattern = try CHHapticPattern(
                events: [firstTap, secondTapTransient, secondTapHeavy, secondTapReinforce],
                parameters: []
            )
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play double haptic: \(error.localizedDescription)")
        }
    }
}

// MARK: - ConfettiView
struct ConfettiView: View {
    let geoSize: CGSize
    @State private var pieces: [ConfettiPiece] = []
    @State private var animate = false
    @State private var confettiPhase: Int = 0
    
    // Generate many confetti pieces that originate from the edges of a simulated Dynamic Island.
    private func generateConfetti() -> [ConfettiPiece] {
        var result: [ConfettiPiece] = []
        let count = 80
        let sides = ["left", "top", "right", "bottom"]
        let piecesPerSide = count / sides.count
        
        // Define a simulated Dynamic Island region (top-center, 200x50)
        let islandWidth: CGFloat = 200
        let islandHeight: CGFloat = 50
        let islandX = (geoSize.width - islandWidth) / 2
        let islandY: CGFloat = 0  // assuming top
        let islandRect = CGRect(x: islandX, y: islandY, width: islandWidth, height: islandHeight)
        
        for side in sides {
            for i in 0..<piecesPerSide {
                let fraction: CGFloat = piecesPerSide > 1 ? CGFloat(i) / CGFloat(piecesPerSide - 1) : 0.5
                var startX: CGFloat = 0
                var startY: CGFloat = 0
                var intermediateX: CGFloat = 0
                var intermediateY: CGFloat = 0
                
                switch side {
                case "left":
                    startX = islandRect.minX - 50
                    startY = islandRect.minY + fraction * islandRect.height
                    intermediateX = startX - 50
                    intermediateY = startY
                case "top":
                    startX = islandRect.minX + fraction * islandRect.width
                    startY = islandRect.minY - 50
                    intermediateX = startX
                    intermediateY = startY - 50
                case "right":
                    startX = islandRect.maxX + 50
                    startY = islandRect.minY + fraction * islandRect.height
                    intermediateX = startX + 50
                    intermediateY = startY
                case "bottom":
                    startX = islandRect.minX + fraction * islandRect.width
                    startY = islandRect.maxY + 50
                    intermediateX = startX
                    intermediateY = startY + 50
                default:
                    break
                }
                
                let finalY = geoSize.height + CGFloat.random(in: 20...100)
                let finalRotation = Double.random(in: 0...720)
                let duration = Double.random(in: 2.5...4.0)
                let delay = Double.random(in: 0...0.3)
                
                result.append(
                    ConfettiPiece(
                        x: startX,
                        y: startY,
                        finalY: finalY,
                        color: .white,
                        finalRotation: finalRotation,
                        duration: duration,
                        delay: delay,
                        intermediateX: intermediateX,
                        intermediateY: intermediateY
                    )
                )
            }
        }
        return result
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    Rectangle()
                        .fill(piece.color)
                        .frame(width: 4, height: 8)
                        .rotationEffect(.degrees(confettiPhase == 2 ? piece.finalRotation : 0))
                        .position(x: piecePosition(for: piece).x, y: piecePosition(for: piece).y)
                        .animation(
                            .linear(duration: piece.duration)
                            .delay(piece.delay),
                            value: confettiPhase
                        )
                }
            }
            .onAppear {
                pieces = generateConfetti()
                withAnimation(Animation.linear(duration: 0.3)) {
                    confettiPhase = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(Animation.linear(duration: 2.0)) {
                        confettiPhase = 2
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func piecePosition(for piece: ConfettiPiece) -> CGPoint {
        switch confettiPhase {
        case 0:
            return CGPoint(x: piece.x, y: piece.y)
        case 1:
            return CGPoint(x: piece.intermediateX, y: piece.intermediateY)
        case 2:
            return CGPoint(x: piece.intermediateX, y: piece.finalY)
        default:
            return CGPoint(x: piece.x, y: piece.y)
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let finalY: CGFloat
    let color: Color
    let finalRotation: Double
    let duration: Double
    let delay: Double
    let intermediateX: CGFloat
    let intermediateY: CGFloat
}

// MARK: - Preview
struct CashOutView_Previews: PreviewProvider {
    static var previews: some View {
        CashOutView()
            .accentColor(.purple)
    }
}
