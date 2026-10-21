import SwiftUI

struct LogoScreen: View {
    @State private var scale: CGFloat = 0.75
    @State private var opacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity: Double = 0
    @State private var pulseAura = false
    @State private var waveAnimation = false
    @State private var orbFloat = false
    
    var body: some View {
        ZStack {
            // MARK: - Deep Luminous Medical Gradient
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.01, green: 0.18, blue: 0.28), location: 0.0), // Deep midnight ocean
                    .init(color: Color(red: 0.02, green: 0.38, blue: 0.50), location: 0.45),
                    .init(color: Color(red: 0.03, green: 0.52, blue: 0.64), location: 1.0)  // Clinical teal
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating ambient light orbs
            GeometryReader { proxy in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "06B6D4").opacity(0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .offset(x: orbFloat ? -20 : -80, y: orbFloat ? -30 : -90)
                    .blur(radius: 40)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "38BDF8").opacity(0.30),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: proxy.size.width - (orbFloat ? 220 : 160), y: proxy.size.height * 0.4)
                    .blur(radius: 45)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // MARK: - Center 3D Logo Medallion
                ZStack {
                    // Concentric acoustic wave ring 1
                    Circle()
                        .stroke(Color(hex: "38BDF8").opacity(0.35), lineWidth: 1.5)
                        .frame(width: 190, height: 190)
                        .scaleEffect(waveAnimation ? 1.35 : 0.95)
                        .opacity(waveAnimation ? 0 : 0.8)
                    
                    // Concentric acoustic wave ring 2
                    Circle()
                        .stroke(Color.white.opacity(0.20), lineWidth: 1.0)
                        .frame(width: 220, height: 220)
                        .scaleEffect(waveAnimation ? 1.45 : 1.0)
                        .opacity(waveAnimation ? 0 : 0.5)
                    
                    // Specular ambient glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "06B6D4").opacity(0.40),
                                    Color(hex: "0284C7").opacity(0.18),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseAura ? 1.15 : 0.95)
                    
                    // Frosted Glass Tile
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 140, height: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.95),
                                            Color.white.opacity(0.30),
                                            Color(hex: "38BDF8").opacity(0.60)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 12)
                        .shadow(color: Color(hex: "06B6D4").opacity(0.40), radius: 14, x: 0, y: 4)
                    
                    // Brand Logo Image
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // MARK: - Brand Identity & Typography
                VStack(spacing: 12) {
                    // Clinical System Pill Badge
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                        Text("ADVANCED CLINICAL AI")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .tracking(1.4)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.18))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.70),
                                        Color(hex: "38BDF8").opacity(0.50)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: Color(hex: "06B6D4").opacity(0.25), radius: 8, x: 0, y: 2)
                    
                    // Primary App Title
                    Text("SIMATS RENAL CALCULI")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(1.2)
                        .shadow(color: Color.black.opacity(0.20), radius: 10, x: 0, y: 4)
                    
                    // Subtitle
                    Text("AI-Assisted Diagnostic & Quantitative Workspace")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .offset(y: textOffset)
                .opacity(textOpacity)
                
                Spacer()
                
                // MARK: - Bottom Clinical Footprint
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "38BDF8"))
                            .scaleEffect(pulseAura ? 1.1 : 0.95)
                        
                        Text("CLINICAL DECISION SUPPORT SYSTEM")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1.4)
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.12))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    
                    Text("SECURE NEPHROLOGY PLATFORM • VERSION 2.0")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.white.opacity(0.45))
                }
                .padding(.bottom, 28)
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.68)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
                textOffset = 0
                textOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulseAura = true
            }
            withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                waveAnimation = true
            }
            withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                orbFloat.toggle()
            }
        }
    }
}

#Preview {
    LogoScreen()
}
