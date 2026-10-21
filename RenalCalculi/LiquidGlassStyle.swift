//
//  LiquidGlassStyle.swift
//  RenalCalculi
//
//  Created for Liquid Glass UI System.
//

import SwiftUI

// MARK: - Color Palette for Liquid Glass
struct LiquidGlassTheme {
    static let primaryTeal = Color(red: 0.0, green: 0.58, blue: 0.65)
    static let vibrantCyan = Color(red: 0.05, green: 0.75, blue: 0.85)
    static let deepIndigo = Color(red: 0.10, green: 0.16, blue: 0.28)
    static let softAzure = Color(red: 0.25, green: 0.62, blue: 0.95)
    static let emeraldSuccess = Color(red: 0.12, green: 0.76, blue: 0.52)
    static let amberWarning = Color(red: 1.0, green: 0.62, blue: 0.18)
    static let coralDanger = Color(red: 0.96, green: 0.36, blue: 0.36)
    static let purpleAccent = Color(red: 0.60, green: 0.38, blue: 0.92)
    
    // High-contrast semantic tokens
    static let textPrimary = Color(hex: "0F172A")    // Slate 900
    static let textSecondary = Color(hex: "334155")  // Slate 700
    static let textMuted = Color(hex: "64748B")      // Slate 500
    static let inputBorder = Color(hex: "CBD5E1")    // Slate 300
    static let inputBgLight = Color.white            // Pure white input surface
    
    static let gradientPrimary = LinearGradient(
        colors: [Color(hex: "0284C7"), Color(hex: "0EA5E9"), Color(hex: "06B6D4")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientCard = LinearGradient(
        colors: [
            Color.white.opacity(0.24),
            Color.white.opacity(0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientBorder = LinearGradient(
        colors: [
            Color.white,
            Color(hex: "38BDF8").opacity(0.5),
            Color.white.opacity(0.7)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Ambient Liquid Glass Background
struct LiquidAmbientBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    var isDarkBackground: Bool? = nil
    @State private var animateOrbs = false
    
    private var isDark: Bool {
        if let explicit = isDarkBackground {
            return explicit
        }
        return colorScheme == .dark
    }
    
    var body: some View {
        ZStack {
            // Base background canvas - rich luminous clinical gradient in light mode
            if isDark {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.07, blue: 0.12),
                        Color(red: 0.03, green: 0.05, blue: 0.09),
                        Color(red: 0.06, green: 0.08, blue: 0.14)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            } else {
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "D8EEF9"), location: 0.0), // Luminous azure sky
                        .init(color: Color(hex: "E8F4FA"), location: 0.32),
                        .init(color: Color(hex: "DCF6F3"), location: 0.68), // Crisp mint/teal glow
                        .init(color: Color(hex: "F1F8FC"), location: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            // Floating liquid refractive orbs
            GeometryReader { proxy in
                // Teal/Sky Orb Top Leading
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "0284C7").opacity(isDark ? 0.40 : 0.38),
                                Color(hex: "06B6D4").opacity(isDark ? 0.25 : 0.20),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .offset(
                        x: animateOrbs ? -20 : -90,
                        y: animateOrbs ? -15 : -70
                    )
                    .blur(radius: 40)
                
                // Azure/Indigo Orb Center Right
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "38BDF8").opacity(isDark ? 0.35 : 0.32),
                                Color(hex: "818CF8").opacity(isDark ? 0.20 : 0.16),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 170
                        )
                    )
                    .frame(width: 340, height: 340)
                    .offset(
                        x: proxy.size.width - (animateOrbs ? 230 : 160),
                        y: proxy.size.height * 0.32 + (animateOrbs ? -30 : 25)
                    )
                    .blur(radius: 45)
                
                // Soft Mint/Emerald Orb Bottom Left
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "0D9488").opacity(isDark ? 0.30 : 0.28),
                                Color(hex: "34D399").opacity(isDark ? 0.18 : 0.14),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .offset(
                        x: animateOrbs ? -10 : -60,
                        y: proxy.size.height - (animateOrbs ? 240 : 170)
                    )
                    .blur(radius: 45)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                animateOrbs.toggle()
            }
        }
    }
}

// MARK: - Liquid Glass Card View Modifier
struct LiquidGlassModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 22
    var opacity: Double = 0.85
    var showBorder: Bool = true
    var shadowRadius: CGFloat = 18
    
    private var isDark: Bool {
        colorScheme == .dark
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: isDark ? [
                                    Color.white.opacity(opacity * 0.10),
                                    Color.white.opacity(opacity * 0.02)
                                ] : [
                                    Color.white.opacity(opacity * 0.92),
                                    Color.white.opacity(opacity * 0.78)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                Group {
                    if showBorder {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: isDark ? [
                                        Color.white.opacity(0.40),
                                        Color.white.opacity(0.10),
                                        LiquidGlassTheme.vibrantCyan.opacity(0.35)
                                    ] : [
                                        Color.white,
                                        Color(hex: "38BDF8").opacity(0.50),
                                        Color.white.opacity(0.80)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                }
            )
            .shadow(color: isDark ? Color.black.opacity(0.40) : Color(hex: "0F172A").opacity(0.09), radius: shadowRadius, x: 0, y: shadowRadius * 0.5)
            .shadow(color: Color(hex: "0284C7").opacity(isDark ? 0.15 : 0.10), radius: 10, x: 0, y: 3)
    }
}

extension View {
    func liquidGlass(
        cornerRadius: CGFloat = 22,
        opacity: Double = 0.85,
        showBorder: Bool = true,
        shadowRadius: CGFloat = 18
    ) -> some View {
        self.modifier(
            LiquidGlassModifier(
                cornerRadius: cornerRadius,
                opacity: opacity,
                showBorder: showBorder,
                shadowRadius: shadowRadius
            )
        )
    }
    
    /// High-contrast, sleek glass textfield container
    func liquidGlassInput(cornerRadius: CGFloat = 14, isFocused: Bool = false) -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        isFocused
                            ? LiquidGlassTheme.vibrantCyan
                            : LiquidGlassTheme.inputBorder,
                        lineWidth: isFocused ? 1.8 : 1.0
                    )
            )
            .shadow(
                color: isFocused ? Color(hex: "0284C7").opacity(0.25) : Color.black.opacity(0.03),
                radius: 6,
                x: 0,
                y: 2
            )
    }
}

// MARK: - Liquid Glass Status Pill
struct LiquidGlassPill: View {
    let title: String
    var icon: String? = nil
    var color: Color = LiquidGlassTheme.primaryTeal
    var isGlowing: Bool = false
    
    var body: some View {
        HStack(spacing: 5) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
            }
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                Capsule()
                    .fill(color.opacity(0.14))
            }
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            color.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: isGlowing ? color.opacity(0.35) : .clear, radius: 5, x: 0, y: 1)
    }
}

// MARK: - Liquid Glass Button Style
struct LiquidGlassButtonStyle: ButtonStyle {
    var isProminent: Bool = true
    var cornerRadius: CGFloat = 16
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Doctor Clinical Badge
struct DoctorClinicalHeaderBadge: View {
    let name: String
    let subtitle: String
    let hospital: String
    var avatarSystemName: String = "stethoscope"
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LiquidGlassTheme.gradientPrimary)
                    .frame(width: 52, height: 52)
                    .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.35), radius: 8, x: 0, y: 4)
                
                Image(systemName: avatarSystemName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(name.isEmpty ? "Dr. Medical Specialist" : name)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundColor(LiquidGlassTheme.vibrantCyan)
                }
                
                Text(subtitle.isEmpty ? "Urologist / Nephrologist" : subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(LiquidGlassTheme.primaryTeal)
                
                if !hospital.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 10))
                        Text(hospital)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(14)
        .liquidGlass(cornerRadius: 20)
    }
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 180, 216)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Modern Liquid Glass Loading View
struct LiquidGlassLoadingView: View {
    var title: String = "SIMATS Medical AI"
    var subtitle: String = "Initializing Clinical Diagnostics Workspace..."
    var badgeText: String = "DIAGNOSTIC ENGINE ACTIVE"
    var icon: String = "waveform.path.ecg"
    
    @State private var pulseWaves = false
    @State private var rotateArc: Double = 0
    @State private var progressValue: CGFloat = 0.15
    @State private var statusStep: Int = 0
    
    let steps: [String] = [
        "Calibrating Neural Vision Weights...",
        "Loading Renal Segmentation Engine...",
        "Configuring Clinical Triage Workspace...",
        "System Ready"
    ]
    
    var body: some View {
        ZStack {
            // Ambient luminous backdrop
            LiquidAmbientBackground()
            
            VStack(spacing: 28) {
                // Central HUD Radar & Medallion
                ZStack {
                    // Outer acoustic pulse ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "38BDF8").opacity(0.45),
                                    Color(hex: "06B6D4").opacity(0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 130, height: 130)
                        .scaleEffect(pulseWaves ? 1.35 : 0.95)
                        .opacity(pulseWaves ? 0 : 0.8)
                    
                    // Counter-rotating outer dashed ring
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .stroke(
                            Color.white.opacity(0.5),
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 6])
                        )
                        .frame(width: 114, height: 114)
                        .rotationEffect(.degrees(-rotateArc * 0.7))
                    
                    // Main rotating cyan gradient arc
                    Circle()
                        .trim(from: 0, to: 0.72)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(hex: "38BDF8"),
                                    Color(hex: "06B6D4")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotateArc))
                    
                    // Frosted glass core medallion
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 82, height: 82)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.95),
                                            Color(hex: "38BDF8").opacity(0.50)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: Color(hex: "0284C7").opacity(0.30), radius: 14, x: 0, y: 6)
                    
                    // Medical pulse waveform icon
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(LiquidGlassTheme.gradientPrimary)
                        .scaleEffect(pulseWaves ? 1.08 : 0.96)
                        .shadow(color: Color(hex: "06B6D4").opacity(0.40), radius: 6, x: 0, y: 2)
                }
                
                // Telemetry & Status Section
                VStack(spacing: 12) {
                    // System status pill
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: "10B981"))
                            .frame(width: 7, height: 7)
                            .shadow(color: Color(hex: "10B981"), radius: 4)
                        
                        Text(badgeText)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(LiquidGlassTheme.primaryTeal)
                            .tracking(1.2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.90))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white, LiquidGlassTheme.primaryTeal.opacity(0.45)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    
                    // Headline
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(LiquidGlassTheme.textPrimary)
                    
                    // Step progress text
                    Text(steps[statusStep % steps.count])
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(LiquidGlassTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .id("status_step_\(statusStep)")
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    
                    // Futuristic glowing progress track
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "CBD5E1").opacity(0.45))
                            .frame(width: 200, height: 5)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "0284C7"),
                                        Color(hex: "06B6D4"),
                                        Color(hex: "10B981")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(20, 200 * progressValue), height: 5)
                            .shadow(color: Color(hex: "0284C7").opacity(0.40), radius: 4, x: 0, y: 1)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                pulseWaves = true
            }
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotateArc = 360
            }
            withAnimation(.easeInOut(duration: 1.2)) {
                progressValue = 0.95
            }
            
            // Cycle status text steps
            Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { timer in
                if statusStep < steps.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        statusStep += 1
                    }
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}
