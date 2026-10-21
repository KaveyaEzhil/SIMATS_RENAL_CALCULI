import SwiftUI

// MARK: - User Selection View (Enhanced Liquid Glass UI)

struct UserSelectionView: View {
    @State private var isAppReady = false
    @State private var showContent = false
    @State private var selectedTab: Int? = nil
    @State private var pulseAnimation = false
    @State private var floatAnimation = false
    
    @State private var loadingProgress: CGFloat = 0.15
    @State private var loadingStepIndex: Int = 0
    
    let loadingSteps: [String] = [
        "Calibrating Neural Vision Network...",
        "Loading Calculus Segmentation Engine...",
        "Configuring Clinical Triage Workspace...",
        "Clinical Intelligence Ready"
    ]
    
    // Persistent sessions
    @AppStorage("doctorDID") private var doctorDID: String = ""
    @AppStorage("patientPID") private var patientPID: String = ""

    var body: some View {
        ZStack {
            // MARK: - Deep Luminous Medical Gradient
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.01, green: 0.44, blue: 0.54), location: 0.0),
                    .init(color: Color(red: 0.02, green: 0.60, blue: 0.72), location: 0.48),
                    .init(color: Color(red: 0.08, green: 0.70, blue: 0.80), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // MARK: - Ambient Liquid Refractive Orbs
            GeometryReader { proxy in
                // Top-left luminous orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.22),
                                Color(hex: "38BDF8").opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .offset(x: -90, y: floatAnimation ? -20 : 30)
                    .blur(radius: 35)
                
                // Bottom-right ethereal orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "06B6D4").opacity(0.28),
                                Color.white.opacity(0.10),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: proxy.size.width - 200, y: proxy.size.height - (floatAnimation ? 340 : 280))
                    .blur(radius: 40)
            }
            .ignoresSafeArea()
            
            if !isAppReady {
                // MARK: - High-End Loading Screen
                loadingScreen
            } else {
                // MARK: - Liquid Glass Selection Screen
                selectionScreen
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
                floatAnimation.toggle()
            }
        }
    }

    // MARK: - Loading Screen
    private var loadingScreen: some View {
        VStack(spacing: 28) {
            ZStack {
                // Outer acoustic pulse ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.40),
                                Color(hex: "38BDF8").opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 130, height: 130)
                    .scaleEffect(pulseAnimation ? 1.35 : 0.95)
                    .opacity(pulseAnimation ? 0 : 0.8)
                    .animation(
                        Animation.easeOut(duration: 1.6).repeatForever(autoreverses: false),
                        value: pulseAnimation
                    )
                
                // Counter-rotating dashed outer ring
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(
                        Color.white.opacity(0.40),
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 6])
                    )
                    .frame(width: 114, height: 114)
                    .rotationEffect(.degrees(showContent ? -360 : 0))
                    .animation(
                        Animation.linear(duration: 2.2).repeatForever(autoreverses: false),
                        value: showContent
                    )
                
                // Main rotating cyan gradient arc
                Circle()
                    .trim(from: 0, to: 0.72)
                    .stroke(
                        LinearGradient(
                            colors: [.white, Color(hex: "38BDF8"), Color(hex: "06B6D4")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(showContent ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1.4).repeatForever(autoreverses: false),
                        value: showContent
                    )
                
                // Frosted glass core
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 82, height: 82)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.90),
                                        Color(hex: "38BDF8").opacity(0.50)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 6)
                
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(pulseAnimation ? 1.08 : 0.96)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseAnimation)
            }
            
            VStack(spacing: 12) {
                // Status Pill
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "34D399"))
                        .frame(width: 7, height: 7)
                        .shadow(color: Color(hex: "34D399"), radius: 4)
                    Text("DIAGNOSTIC ENGINE ACTIVE")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(1.2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.20))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                )
                
                Text("SIMATS Medical AI")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(loadingSteps[loadingStepIndex % loadingSteps.count])
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .id("user_selection_step_\(loadingStepIndex)")
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
                // Futuristic Glowing Progress Track
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.20))
                        .frame(width: 200, height: 5)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(hex: "38BDF8"),
                                    Color(hex: "34D399")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(20, 200 * loadingProgress), height: 5)
                        .shadow(color: Color(hex: "38BDF8").opacity(0.50), radius: 4, x: 0, y: 1)
                }
                .padding(.top, 4)
            }
        }
        .onAppear {
            pulseAnimation = true
            showContent = true
            initializeApp()
        }
    }

    // MARK: - Selection Screen UI
    private var selectionScreen: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)
            
            // MARK: - Logo & Brand Header
            VStack(spacing: 16) {
                // 3D Frosted Glass Logo Medallion
                ZStack {
                    // Specular ambient glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.28),
                                    Color(hex: "06B6D4").opacity(0.18),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 90
                            )
                        )
                        .frame(width: 170, height: 170)
                        .scaleEffect(showContent ? 1.0 : 0.7)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.65), value: showContent)
                    
                    // Glass Medallion Tile
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 110, height: 110)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color.white.opacity(0.3),
                                            Color(hex: "38BDF8").opacity(0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: Color.black.opacity(0.14), radius: 16, x: 0, y: 8)
                        .shadow(color: Color(hex: "06B6D4").opacity(0.3), radius: 10, x: 0, y: 4)
                    
                    // Kidney Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.75, dampingFraction: 0.68).delay(0.1), value: showContent)
                }
                .frame(height: 140)
                
                // Typography
                VStack(spacing: 8) {
                    // Clinical System Pill
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .bold))
                        Text("CLINICAL AI PLATFORM")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .tracking(1.2)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.18))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    
                    Text("SIMATS RENAL CALCULI")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(0.5)
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
                    
                    Text("AI-Assisted Diagnostic & Physician Review Workspace")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                .offset(y: showContent ? 0 : 25)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.7).delay(0.2), value: showContent)
            }
            .padding(.top, 10)
            
            Spacer(minLength: 30)

            // MARK: - Dual Liquid Glass Portal Cards
            VStack(spacing: 16) {
                // Doctor Portal Card
                NavigationLink(destination: DoctorLoginView()) {
                    portalCard(
                        title: "Doctor Portal",
                        subtitle: "Review & Diagnose Clinical Cases",
                        icon: "stethoscope",
                        accentGradient: LinearGradient(
                            colors: [Color(hex: "0284C7"), Color(hex: "06B6D4")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        index: 0
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(selectedTab == 0 ? 0.97 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab == 0)
                .offset(y: showContent ? 0 : 40)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.7).delay(0.35), value: showContent)
                
                // Patient Portal Card
                NavigationLink(destination: PatientLoginView()) {
                    portalCard(
                        title: "Patient Portal",
                        subtitle: "View Diagnostic Results & History",
                        icon: "person.fill",
                        accentGradient: LinearGradient(
                            colors: [Color(hex: "0D9488"), Color(hex: "14B8A6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        index: 1
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(selectedTab == 1 ? 0.97 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab == 1)
                .offset(y: showContent ? 0 : 40)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.7).delay(0.45), value: showContent)
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 30)

            // MARK: - Footer
            VStack(spacing: 6) {
                Text("© 2025 SIMATS Renal Calculi • Precision Diagnostics")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                
                Text("v1.0.0 • Verified Academic & Clinical Research")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.bottom, 24)
            .offset(y: showContent ? 0 : 20)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.7).delay(0.55), value: showContent)
        }
    }

    // MARK: - Unified Liquid Glass Portal Card Helper
    private func portalCard(title: String, subtitle: String, icon: String, accentGradient: LinearGradient, index: Int) -> some View {
        HStack(spacing: 16) {
            // Illuminated Icon Medallion
            ZStack {
                Circle()
                    .fill(accentGradient)
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Text Details
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.08, green: 0.16, blue: 0.24))
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.25, green: 0.38, blue: 0.48))
            }
            
            Spacer()
            
            // Glass Chevron Medallion
            ZStack {
                Circle()
                    .fill(Color(red: 0.0, green: 0.58, blue: 0.65).opacity(0.12))
                    .frame(width: 34, height: 34)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.52, blue: 0.60))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.92),
                                Color.white.opacity(0.80)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.white.opacity(0.4),
                            Color(hex: "06B6D4").opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 7)
        .shadow(color: Color(hex: "06B6D4").opacity(0.18), radius: 6, x: 0, y: 2)
    }

    // MARK: - Enhanced Initialization
    func initializeApp() {
        print("🔑 Initializing User Selection...")
        withAnimation(.easeInOut(duration: 1.1)) {
            loadingProgress = 0.95
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { timer in
            if loadingStepIndex < loadingSteps.count - 1 {
                withAnimation(.easeInOut(duration: 0.25)) {
                    loadingStepIndex += 1
                }
            } else {
                timer.invalidate()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isAppReady = true
            }
        }
    }
}

#Preview {
    UserSelectionView()
}
