import SwiftUI

// --------------------------------------------------
// MARK: - LAST REPORT MODELS
// --------------------------------------------------
struct LastReport: Codable {
    let size: [String]
    let count: Int
    let location: [String]
}

struct LastReportResponse: Codable {
    let success: Bool
    let last_report: LastReport?
    let debug_pid_searched: String?
}

// ✅ NEW: Doctor Review Notification Model
struct DoctorReviewNotification: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: Date
}

// --------------------------------------------------
// MARK: - TAB IDENTIFIER (SINGLE SOURCE OF TRUTH)
// --------------------------------------------------
enum LiquidTab: Int, CaseIterable {
    case home = 0
    case reports
    case profile
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .reports: return "Reports"
        case .profile: return "Profile"
        case .settings: return "Settings"
        }
    }

    var systemImageName: String {
        switch self {
        case .home: return "house"
        case .reports: return "doc.text"
        case .profile: return "person"
        case .settings: return "gearshape"
        }
    }

    var systemImageNameFilled: String {
        switch self {
        case .home: return "house.fill"
        case .reports: return "doc.text.fill"
        case .profile: return "person.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// --------------------------------------------------
// MARK: - MAIN PATIENT DASHBOARD VIEW
// --------------------------------------------------
struct PatientDashboardView: View {
    @State private var selectedTab: LiquidTab = .home
    @State private var navigateToUserSelection = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Namespace private var tabNamespace
    @AppStorage("patientPID") var patientPID: String = ""
    @State private var patientName: String = ""
    @State private var showSidebar = false

    // ✅ NEW: Doctor review notification state
    @State private var doctorReviewNotifications: [DoctorReviewNotification] = []
    @AppStorage("hasSeenDoctorReviewNotification") private var hasSeenNotification = false

    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Main Tab Content
                Group {
                    switch selectedTab {
                    case .home:
                        PatientDashboardContent(
                            pid: patientPID,
                            patientName: $patientName,
                            doctorReviewNotifications: $doctorReviewNotifications,
                            hasSeenNotification: $hasSeenNotification,
                            selectedTab: $selectedTab,
                            showSidebar: $showSidebar
                        )

                    case .reports:
                        ReportsHistoryContent(pid: patientPID)
                    case .profile:
                        PatientProfileContent(pid: patientPID)
                    case .settings:
                        PatientSettingsView(pid: patientPID)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)

                // MARK: - Floating Tab Bar (only on main tabs)
                VStack {
                    Spacer()
                    if [.home, .reports, .profile, .settings].contains(selectedTab) {
                        LiquidTabBar(
                            selectedTab: $selectedTab,
                            namespace: tabNamespace,
                            notificationCount: doctorReviewNotifications.count
                        )
                            .padding(.horizontal, 18)
                            .padding(.bottom, 12)
                    }
                }

                // MARK: - Twitter/iOS-style Patient Sidebar Overlay
                if showSidebar {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showSidebar = false
                            }
                        }

                    HStack {
                        PatientSidebarView(
                            showSidebar: $showSidebar,
                            selectedTab: $selectedTab,
                            navigateToUserSelection: $navigateToUserSelection
                        )
                        .frame(width: min(UIScreen.main.bounds.width * 0.82, 310))
                        .background(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.25), radius: 15, x: 5, y: 0)
                        .transition(.move(edge: .leading))

                        Spacer()
                    }
                    .zIndex(100)
                    .ignoresSafeArea()
                }

                // MARK: - Hidden NavigationLink
                NavigationLink(
                    "",
                    destination: LogoScreen(),
                    isActive: $navigateToUserSelection
                )
                .hidden()
            }
            .frame(maxWidth: .infinity)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}


// --------------------------------------------------
// MARK: - LIQUID TAB BAR COMPONENT (WITH BADGE & VISIONOS GLASS)
// --------------------------------------------------
struct LiquidTabBar: View {
    @Binding var selectedTab: LiquidTab
    var namespace: Namespace.ID
    var notificationCount: Int
    @Environment(\.colorScheme) var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(LiquidTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab

                Button {
                    if selectedTab != tab {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                            selectedTab = tab
                        }
                    }
                } label: {
                    VStack(spacing: 3) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: isSelected ? tab.systemImageNameFilled : tab.systemImageName)
                                .font(.system(size: isSelected ? 19 : 18, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(
                                    isSelected
                                        ? AnyShapeStyle(LiquidGlassTheme.gradientPrimary)
                                        : AnyShapeStyle(isDark ? Color.white.opacity(0.65) : Color.secondary.opacity(0.8))
                                )
                                .scaleEffect(isSelected ? 1.08 : 1.0)

                            // Glowing notification badge on Reports tab
                            if tab == .reports && notificationCount > 0 {
                                ZStack {
                                    Capsule()
                                        .fill(Color(hex: "F43F5E"))
                                        .frame(height: 16)
                                        .frame(minWidth: 16)
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(Color.white, lineWidth: 1)
                                        )
                                        .shadow(color: Color(hex: "F43F5E").opacity(0.4), radius: 4)

                                    Text("\(notificationCount)")
                                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                }
                                .offset(x: 12, y: -8)
                            }
                        }

                        Text(tab.title)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                            .foregroundStyle(
                                isSelected
                                    ? AnyShapeStyle(LiquidGlassTheme.primaryTeal)
                                    : AnyShapeStyle(isDark ? Color.white.opacity(0.65) : Color.secondary.opacity(0.85))
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .contentShape(Rectangle())
                    .background(
                        ZStack {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                LiquidGlassTheme.primaryTeal.opacity(isDark ? 0.35 : 0.16),
                                                LiquidGlassTheme.vibrantCyan.opacity(isDark ? 0.22 : 0.08)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [
                                                        LiquidGlassTheme.vibrantCyan.opacity(isDark ? 0.8 : 0.6),
                                                        LiquidGlassTheme.primaryTeal.opacity(isDark ? 0.5 : 0.3)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.2
                                            )
                                    )
                                    .matchedGeometryEffect(id: "PATIENT_ACTIVE_TAB_PILL", in: namespace)
                                    .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.25), radius: 6, x: 0, y: 2)
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            ZStack {
                // Frosted glass base
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(isDark ? Color(hex: "0A101D").opacity(0.85) : Color.white.opacity(0.88))
                    .background(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )

                // Specular sheen overlay
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isDark ? [
                                Color(hex: "38BDF8").opacity(0.08),
                                Color.white.opacity(0.02)
                            ] : [
                                Color.white.opacity(0.40),
                                Color.white.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Specular rim stroke
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: isDark ? [
                                Color.white.opacity(0.25),
                                LiquidGlassTheme.vibrantCyan.opacity(0.45),
                                Color.white.opacity(0.06)
                            ] : [
                                Color.white.opacity(0.95),
                                Color.white.opacity(0.45),
                                LiquidGlassTheme.vibrantCyan.opacity(0.30)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            }
        )
        .shadow(color: isDark ? Color.black.opacity(0.65) : Color.black.opacity(0.08), radius: 18, x: 0, y: 8)
        .shadow(color: LiquidGlassTheme.vibrantCyan.opacity(isDark ? 0.20 : 0.08), radius: 12, x: 0, y: 4)
    }
}

// --------------------------------------------------
// MARK: - PARSED STONE MODEL & CLINICAL HELPERS
// --------------------------------------------------
struct ParsedStone: Identifiable {
    let id = UUID()
    let index: Int
    let sizeText: String
    let sizeValue: Double?
    let location: String
    
    var severityColor: Color {
        guard let size = sizeValue else { return LiquidGlassTheme.softAzure }
        if size >= 20 { return LiquidGlassTheme.coralDanger }
        if size >= 10 { return LiquidGlassTheme.amberWarning }
        if size >= 5 { return LiquidGlassTheme.softAzure }
        return LiquidGlassTheme.emeraldSuccess
    }
    
    var severityLabel: String {
        guard let size = sizeValue else { return "Calculus" }
        if size >= 20 { return "Large / Staghorn (≥20mm)" }
        if size >= 10 { return "Substantial (10–20mm)" }
        if size >= 5 { return "Moderate (5–10mm)" }
        return "Passable (<5mm)"
    }
}

// --------------------------------------------------
// MARK: - PATIENT SIDEBAR VIEW (Liquid Glass)
// --------------------------------------------------
struct PatientSidebarView: View {
    @Binding var showSidebar: Bool
    @Binding var selectedTab: LiquidTab
    @Binding var navigateToUserSelection: Bool

    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("patientPID") private var patientPID: String = ""
    @AppStorage("patientName") private var patientName: String = ""
    @AppStorage("patientEmail") private var patientEmail: String = ""
    @AppStorage("patientPhone") private var patientPhone: String = ""
    @AppStorage("patientAge") private var patientAge: String = ""
    @AppStorage("patientGender") private var patientGender: String = ""
    @AppStorage("patientAddress") private var patientAddress: String = ""
    @AppStorage("patientWork") private var patientWork: String = ""
    @AppStorage("doctorLogin") private var doctorLogin: Bool = false
    @AppStorage("patientLogin") private var patientLogin: Bool = false

    @State private var showLogoutAlert = false
    @State private var showHelp = false
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showAbout = false
    @State private var animateHeader = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // HEADER
                patientProfileHeader
                    .opacity(animateHeader ? 1 : 0)
                    .offset(y: animateHeader ? 0 : -16)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.35)) {
                            animateHeader = true
                        }
                    }

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .opacity(0.2)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // NAVIGATION ITEMS
                        VStack(spacing: 10) {
                            SidebarButton(
                                icon: "person.crop.square.fill",
                                title: "My Health Profile",
                                subtitle: "Clinical ID & Medical Vitals"
                            ) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    selectedTab = .profile
                                    showSidebar = false
                                }
                            }

                            SidebarButton(
                                icon: "waveform.path.ecg.rectangle.fill",
                                title: "Diagnostic Reports",
                                subtitle: "Radiology analyses & stones"
                            ) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    selectedTab = .reports
                                    showSidebar = false
                                }
                            }

                            SidebarButton(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                subtitle: "Renal care guidance & FAQs"
                            ) {
                                showHelp = true
                            }

                            SidebarButton(
                                icon: "shield.fill",
                                title: "Privacy Policy",
                                subtitle: "HIPAA & health data standards"
                            ) {
                                showPrivacy = true
                            }

                            SidebarButton(
                                icon: "doc.text.fill",
                                title: "Terms & Conditions",
                                subtitle: "Diagnostic usage terms"
                            ) {
                                showTerms = true
                            }

                            SidebarButton(
                                icon: "info.circle.fill",
                                title: "About Renal Calculi",
                                subtitle: "AI vision model & telemetry"
                            ) {
                                showAbout = true
                            }
                        }
                        .padding(.horizontal, 16)

                        Divider()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .opacity(0.2)

                        // SETTINGS SECTION - DARK MODE
                        VStack(spacing: 10) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: isDarkMode ?
                                                    [Color(hex: "8B5CF6").opacity(0.25), Color(hex: "6366F1").opacity(0.15)] :
                                                    [Color(hex: "F59E0B").opacity(0.22), Color(hex: "EAB308").opacity(0.12)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(isDarkMode ? Color(hex: "A78BFA").opacity(0.3) : Color(hex: "FBBF24").opacity(0.4), lineWidth: 1)
                                        )

                                    Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(
                                            isDarkMode ?
                                                LinearGradient(colors: [Color(hex: "A78BFA"), Color(hex: "818CF8")], startPoint: .top, endPoint: .bottom) :
                                                LinearGradient(colors: [Color(hex: "FBBF24"), Color(hex: "F59E0B")], startPoint: .top, endPoint: .bottom)
                                        )
                                        .shadow(color: isDarkMode ? Color(hex: "A78BFA").opacity(0.5) : Color(hex: "FBBF24").opacity(0.4), radius: 4)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Dark Mode")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)

                                    Text(isDarkMode ? "Dark Clinical Mode" : "Light Hospital Mode")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer(minLength: 6)

                                Toggle("", isOn: Binding(
                                    get: { isDarkMode },
                                    set: { val in
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            isDarkMode = val
                                        }
                                    }
                                ))
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "06B6D4")))
                                .scaleEffect(0.85)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(.secondarySystemBackground).opacity(0.65))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Color.white.opacity(isDarkMode ? 0.12 : 0.6), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 16)

                        // LOGOUT / SIGN OUT BUTTON
                        Button(action: { showLogoutAlert = true }) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "arrow.right.to.line")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(hex: "EF4444"))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Patient Sign Out")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color(hex: "EF4444"))
                                    Text("Terminate active session")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(hex: "EF4444").opacity(0.7))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.red.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        // FOOTER
                        VStack(spacing: 4) {
                            Text("Renal Calculi Patient Care Platform")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("v1.0 • AI-Driven Calculus Telemetry")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .alert("Confirm Patient Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) { performLogout() }
        } message: {
            Text("Are you sure you want to log out of your patient portal? You will need to sign in again to access your records.")
        }
        .fullScreenCover(isPresented: $showHelp) {
            NavigationStack {
                HelpSupportDoctorView()
            }
        }
        .fullScreenCover(isPresented: $showPrivacy) {
            NavigationStack {
                PrivacyPolicyDoctorView()
            }
        }
        .fullScreenCover(isPresented: $showTerms) {
            NavigationStack {
                TermsConditionsDoctorView()
            }
        }
        .fullScreenCover(isPresented: $showAbout) {
            NavigationStack {
                AboutNephrolithView()
            }
        }
    }

    private var patientProfileHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                // Profile Avatar with Glow
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "0284C7"), Color(hex: "06B6D4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .shadow(color: Color(hex: "06B6D4").opacity(0.35), radius: 6, y: 3)

                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(patientName.isEmpty ? "Patient" : patientName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(patientEmail.isEmpty ? (patientPID.isEmpty ? "Patient Portal" : "PID: \(patientPID)") : patientEmail)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }

            // Clinical Presence Pill
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 11))
                    .foregroundColor(LiquidGlassTheme.primaryTeal)

                Text(patientPID.isEmpty ? "Patient Portal" : "ID: \(patientPID)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: "10B981"))
                        .frame(width: 6, height: 6)
                        .shadow(color: Color(hex: "10B981"), radius: 3)

                    Text("Active")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "10B981"))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(hex: "06B6D4").opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "06B6D4").opacity(0.25), lineWidth: 1)
                    )
            )
        }
        .padding(18)
        .background(
            Color(.secondarySystemBackground).opacity(0.5)
        )
    }

    private func performLogout() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showSidebar = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            patientPID = ""
            patientName = ""
            patientEmail = ""
            patientPhone = ""
            patientAge = ""
            patientGender = ""
            patientAddress = ""
            patientWork = ""
            doctorLogin = false
            patientLogin = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                navigateToUserSelection = true
            }
        }
    }
}

// --------------------------------------------------
// MARK: - PATIENT DASHBOARD CONTENT (WITH API INTEGRATION)
// --------------------------------------------------
struct PatientDashboardContent: View {
    var pid: String
    @Binding var patientName: String
    @Binding var doctorReviewNotifications: [DoctorReviewNotification]
    @Binding var hasSeenNotification: Bool
    @Binding var selectedTab: LiquidTab
    @Binding var showSidebar: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }
    
    @State private var showHeader = false
    @State private var showCards = false
    @State private var lastReport: LastReport?
    @State private var isLoadingReport = false
    @State private var errorMessage: String?
    @State private var isBreakdownExpanded = false
    @State private var cardPulsing = false

    var body: some View {
        ZStack {
            // Ambient Liquid Glass Canvas with animated orbs
            LiquidAmbientBackground()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    // MARK: - Top Header Section
                    headerSection
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .scaleEffect(showHeader ? 1 : 0.94)
                        .opacity(showHeader ? 1 : 0)

                    // MARK: - Doctor Review Alert (if unread)
                    if !doctorReviewNotifications.isEmpty {
                        doctorReviewBanner
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // MARK: - Upload CT Scan Hero Card
                    uploadHeroCard
                        .padding(.horizontal, 20)
                        .scaleEffect(showCards ? 1 : 0.95)
                        .opacity(showCards ? 1 : 0)

                    // MARK: - Recent Report Diagnostic Summary
                    lastReportSummaryCard
                        .padding(.horizontal, 20)
                        .scaleEffect(showCards ? 1 : 0.95)
                        .opacity(showCards ? 1 : 0)

                    // MARK: - Daily Renal Guidance & Hydration
                    renalGuidanceCard
                        .padding(.horizontal, 20)
                        .scaleEffect(showCards ? 1 : 0.95)
                        .opacity(showCards ? 1 : 0)

                    // Bottom padding for floating liquid tab bar
                    Color.clear.frame(height: 110)
                }
            }
            .refreshable {
                fetchLastReport()
                fetchPatientName()
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                showHeader = true
            }
            withAnimation(.spring(response: 0.75, dampingFraction: 0.85).delay(0.12)) {
                showCards = true
            }
            fetchLastReport()
            fetchPatientName()
            
            if !hasSeenNotification {
                checkForDoctorReview()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 14) {
            // Hamburger Sidebar Button
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    showSidebar = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(isDark ? Color.white.opacity(0.12) : Color(.secondarySystemBackground).opacity(0.85))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                }
                .overlay(
                    Circle()
                        .strokeBorder(isDark ? Color.white.opacity(0.25) : Color.white.opacity(0.6), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            }

            VStack(alignment: .leading, spacing: 6) {
                // Status telemetry pill
                HStack(spacing: 6) {
                    Circle()
                        .fill(LiquidGlassTheme.emeraldSuccess)
                        .frame(width: 8, height: 8)
                        .shadow(color: LiquidGlassTheme.emeraldSuccess.opacity(0.8), radius: 4)
                    
                    Text("PATIENT CLINICAL HUB")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                        .tracking(0.8)
                    
                    Text("• AI v2.4")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 3.5)
                .background(
                    Capsule()
                        .fill(LiquidGlassTheme.primaryTeal.opacity(isDark ? 0.20 : 0.10))
                        .overlay(
                            Capsule()
                                .strokeBorder(LiquidGlassTheme.primaryTeal.opacity(0.3), lineWidth: 1)
                        )
                )

                Text("Welcome, \(patientName.isEmpty ? "Patient" : patientName) 👋")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: isDark ? [.white, Color(hex: "E2E8F0")] : [LiquidGlassTheme.textPrimary, Color(hex: "1E293B")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text("Your Health, Our Priority.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isDark ? Color.white.opacity(0.7) : LiquidGlassTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Profile Medallion / Quick switch
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    selectedTab = .profile
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isDark ? [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.06)
                                ] : [
                                    Color.white,
                                    Color(hex: "E0F2FE")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(isDark ? 0.5 : 0.9),
                                            LiquidGlassTheme.vibrantCyan.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.20), radius: 8, x: 0, y: 4)

                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [LiquidGlassTheme.vibrantCyan, LiquidGlassTheme.primaryTeal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Doctor Review Alert Banner
    private var doctorReviewBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LiquidGlassTheme.emeraldSuccess.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: "stethoscope")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(LiquidGlassTheme.emeraldSuccess)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Doctor Review Available")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(LiquidGlassTheme.emeraldSuccess)
                    
                    Circle()
                        .fill(LiquidGlassTheme.emeraldSuccess)
                        .frame(width: 6, height: 6)
                }
                
                Text("Your recent scan has been reviewed. Tap to view notes.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isDark ? Color.white.opacity(0.85) : LiquidGlassTheme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    selectedTab = .reports
                }
            }) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(LiquidGlassTheme.emeraldSuccess)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isDark ? Color(hex: "064E3B").opacity(0.35) : Color(hex: "ECFDF5"))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(LiquidGlassTheme.emeraldSuccess.opacity(0.4), lineWidth: 1.2)
                )
        )
    }

    // MARK: - Upload CT Scan Hero Card
    private var uploadHeroCard: some View {
        NavigationLink(destination: UploadCTScanView()) {
            ZStack {
                // Background Gradient
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "0284C7"),
                                Color(hex: "0EA5E9"),
                                Color(hex: "06B6D4")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Subtle water/organic refraction highlight
                GeometryReader { geo in
                    Path { path in
                        let w = geo.size.width
                        let h = geo.size.height
                        path.move(to: CGPoint(x: w * 0.75, y: 0))
                        path.addCurve(
                            to: CGPoint(x: w, y: h * 0.45),
                            control1: CGPoint(x: w * 0.88, y: h * 0.15),
                            control2: CGPoint(x: w * 0.96, y: h * 0.28)
                        )
                        path.addLine(to: CGPoint(x: w, y: 0))
                        path.closeSubpath()
                    }
                    .fill(Color.white.opacity(0.15))
                }

                // Card Content
                VStack(spacing: 16) {
                    // Top Telemetry Header
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 6, height: 6)
                                .shadow(color: .white, radius: 3)
                            Text("AI SEGMENTATION READY")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .tracking(1.0)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.20)))

                        Spacer()

                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    // 3D Concentric Upload Icon Medallion
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 84, height: 84)
                        
                        Circle()
                            .fill(Color.white.opacity(0.26))
                            .frame(width: 68, height: 68)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.4), lineWidth: 1.5)
                            )

                        Image(systemName: "arrow.up.doc.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                    }
                    .padding(.vertical, 2)

                    // Text Content
                    VStack(spacing: 4) {
                        Text("Upload CT Scan")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)

                        Text("Instant automated calculus detection, size measurement & spatial localization")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }

                    // Action Capsule Button
                    HStack(spacing: 8) {
                        Text("Start Diagnostic Scan")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "0369A1"))
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "0369A1"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.75),
                                Color.white.opacity(0.20),
                                Color.white.opacity(0.40)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color(hex: "0284C7").opacity(isDark ? 0.45 : 0.32), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(CardPressStyle())
    }

    // MARK: - Last Report Summary Card
    private var lastReportSummaryCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header Row
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LiquidGlassTheme.primaryTeal.opacity(isDark ? 0.25 : 0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: "waveform.path.ecg.rectangle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Last Report Summary")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isDark ? .white : LiquidGlassTheme.textPrimary)
                    
                    Text("Automated Radiology Segmentation")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isDark ? Color.white.opacity(0.65) : LiquidGlassTheme.textMuted)
                }

                Spacer()

                if lastReport != nil {
                    Text("AI Verified")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(LiquidGlassTheme.primaryTeal.opacity(isDark ? 0.20 : 0.10))
                        )
                }
            }

            Divider()
                .overlay(
                    LinearGradient(
                        colors: [
                            LiquidGlassTheme.primaryTeal.opacity(0.5),
                            LiquidGlassTheme.vibrantCyan.opacity(0.1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            // Content Body
            if let report = lastReport {
                reportContentBody(report: report)
            } else if isLoadingReport {
                HStack(spacing: 14) {
                    ProgressView()
                        .tint(LiquidGlassTheme.primaryTeal)
                    Text("Retrieving latest renal diagnostic metrics...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isDark ? Color.white.opacity(0.7) : LiquidGlassTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 24)
            } else if let error = errorMessage {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(LiquidGlassTheme.amberWarning)
                    Text(error)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isDark ? Color.white.opacity(0.8) : LiquidGlassTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: fetchLastReport) {
                        Text("Retry")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(LiquidGlassTheme.primaryTeal)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(LiquidGlassTheme.primaryTeal.opacity(0.15)))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(LiquidGlassTheme.textMuted.opacity(0.7))
                    Text("No scans uploaded yet")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(isDark ? .white : LiquidGlassTheme.textPrimary)
                    Text("Upload your first CT scan using the card above to generate instant calculus telemetry.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isDark ? Color.white.opacity(0.65) : LiquidGlassTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    isDark ?
                    Color(hex: "0F172A").opacity(0.75) :
                    Color.white.opacity(0.92)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isDark ? 0.35 : 0.95),
                                    Color(hex: "38BDF8").opacity(isDark ? 0.25 : 0.40),
                                    Color.white.opacity(isDark ? 0.10 : 0.60)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.4
                        )
                )
        )
        .shadow(color: isDark ? Color.black.opacity(0.40) : Color(hex: "0F172A").opacity(0.08), radius: 18, x: 0, y: 8)
        .shadow(color: LiquidGlassTheme.primaryTeal.opacity(isDark ? 0.15 : 0.08), radius: 12, x: 0, y: 4)
    }

    // MARK: - Report Content Body (4-Metric Grid + Stone Breakdown)
    @ViewBuilder
    private func reportContentBody(report: LastReport) -> some View {
        let maxInfo = maxStoneInfo(report.size)
        let locSummary = summarizeLocations(report.location)
        let parsedList = parseStones(sizes: report.size, locations: report.location)

        VStack(spacing: 16) {
            // 2x2 Metric Indicator Grid
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                // Metric 1: Total Count
                PatientMetricTile(
                    title: "TOTAL CALCULI",
                    value: "\(report.count)",
                    subtext: report.count == 0 ? "Clean Scan" : "\(report.count) Detected",
                    icon: "circle.grid.2x2.fill",
                    accentColor: report.count == 0 ? LiquidGlassTheme.emeraldSuccess : LiquidGlassTheme.primaryTeal
                )

                // Metric 2: Max Diameter
                PatientMetricTile(
                    title: "MAX DIAMETER",
                    value: maxInfo.text,
                    subtext: maxInfo.severity,
                    icon: "ruler.fill",
                    accentColor: maxInfo.color
                )

                // Metric 3: Laterality / Site
                PatientMetricTile(
                    title: "LOCALIZATION",
                    value: locSummary,
                    subtext: "Site Laterality",
                    icon: "mappin.and.ellipse",
                    accentColor: LiquidGlassTheme.softAzure
                )

                // Metric 4: Clinical Guidance
                PatientMetricTile(
                    title: "CARE PATHWAY",
                    value: report.count > 0 ? "Doctor Consult" : "Routine Check",
                    subtext: report.count > 0 ? "Clinical Protocol" : "Hydration",
                    icon: "cross.case.fill",
                    accentColor: report.count > 0 ? LiquidGlassTheme.amberWarning : LiquidGlassTheme.emeraldSuccess
                )
            }

            // Stone Breakdown Section (if stones present)
            if !parsedList.isEmpty {
                VStack(spacing: 10) {
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isBreakdownExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Calculi Breakdown (\(parsedList.count))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(isDark ? .white : LiquidGlassTheme.textPrimary)

                            Spacer()

                            HStack(spacing: 4) {
                                Text(isBreakdownExpanded ? "Hide" : "View List")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(LiquidGlassTheme.primaryTeal)

                                Image(systemName: isBreakdownExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(LiquidGlassTheme.primaryTeal)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())

                    if isBreakdownExpanded {
                        VStack(spacing: 8) {
                            ForEach(parsedList) { stone in
                                PatientStoneRow(stone: stone)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isDark ? Color.white.opacity(0.04) : Color(hex: "F8FAFC"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(isDark ? Color.white.opacity(0.08) : Color(hex: "E2E8F0"), lineWidth: 1)
                        )
                )
            }

            // Full History CTA Link
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    selectedTab = .reports
                }
            }) {
                HStack(spacing: 8) {
                    Text("View Detailed Radiology Report")
                        .font(.system(size: 14, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(LiquidGlassTheme.primaryTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LiquidGlassTheme.primaryTeal.opacity(isDark ? 0.18 : 0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(LiquidGlassTheme.primaryTeal.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Renal Care & Guidance Card
    private var renalGuidanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LiquidGlassTheme.softAzure.opacity(0.18))
                        .frame(width: 36, height: 36)
                    Image(systemName: "drop.fill")
                        .font(.system(size: 18))
                        .foregroundColor(LiquidGlassTheme.softAzure)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Renal Care & Prevention")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isDark ? .white : LiquidGlassTheme.textPrimary)
                    Text("Clinical Hydration & Wellness Protocol")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isDark ? Color.white.opacity(0.65) : LiquidGlassTheme.textMuted)
                }
                Spacer()
            }

            VStack(spacing: 10) {
                GuidanceRow(
                    icon: "drop.circle.fill",
                    iconColor: Color(hex: "0284C7"),
                    title: "Hydration Target: 2.5L – 3.0L / day",
                    subtitle: "Dilutes urine solute concentration to inhibit calculus recrystallization."
                )

                GuidanceRow(
                    icon: "fork.knife.circle.fill",
                    iconColor: Color(hex: "10B981"),
                    title: "Dietary Balance",
                    subtitle: "Moderate sodium intake (<2g/day) and maintain adequate dietary calcium."
                )

                GuidanceRow(
                    icon: "cross.circle.fill",
                    iconColor: Color(hex: "F59E0B"),
                    title: "Emergency Symptoms",
                    subtitle: "Contact a physician promptly if experiencing acute colicky flank pain or fever."
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(isDark ? Color(hex: "0F172A").opacity(0.70) : Color.white.opacity(0.90))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isDark ? 0.30 : 0.90),
                                    LiquidGlassTheme.softAzure.opacity(isDark ? 0.20 : 0.35)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
        )
        .shadow(color: isDark ? Color.black.opacity(0.35) : Color(hex: "0F172A").opacity(0.06), radius: 14, x: 0, y: 6)
    }

    // MARK: - Clinical Parsing Helpers
    private func parseStones(sizes: [String], locations: [String]) -> [ParsedStone] {
        let count = max(sizes.count, locations.count)
        var result: [ParsedStone] = []
        for i in 0..<count {
            let sizeStr = i < sizes.count ? sizes[i].trimmingCharacters(in: .whitespacesAndNewlines) : "N/A"
            let locStr = i < locations.count ? locations[i].trimmingCharacters(in: .whitespacesAndNewlines) : "Kidney"
            
            let clean = sizeStr
                .replacingOccurrences(of: "mm", with: "")
                .replacingOccurrences(of: "MM", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let val = Double(clean)
            
            result.append(
                ParsedStone(
                    index: i + 1,
                    sizeText: sizeStr.contains("mm") ? sizeStr : (val != nil ? "\(sizeStr) mm" : sizeStr),
                    sizeValue: val,
                    location: locStr.isEmpty ? "Kidney" : locStr
                )
            )
        }
        return result
    }

    private func summarizeLocations(_ locations: [String]) -> String {
        guard !locations.isEmpty else { return "Kidney" }
        var counts: [String: Int] = [:]
        for loc in locations {
            let clean = loc.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !clean.isEmpty else { continue }
            counts[clean, default: 0] += 1
        }
        guard !counts.isEmpty else { return "Kidney" }
        if counts.count == 1, let (name, count) = counts.first {
            return count > 1 ? "\(name) (\(count))" : name
        }
        return counts.map { "\($0.key) (\($0.value))" }.joined(separator: ", ")
    }

    private func maxStoneInfo(_ sizes: [String]) -> (text: String, value: Double?, severity: String, color: Color) {
        guard !sizes.isEmpty else {
            return ("None", nil, "Clear", LiquidGlassTheme.emeraldSuccess)
        }
        var maxVal: Double? = nil
        var maxStr = "N/A"
        for s in sizes {
            let clean = s
                .replacingOccurrences(of: "mm", with: "")
                .replacingOccurrences(of: "MM", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let val = Double(clean) {
                if maxVal == nil || val > maxVal! {
                    maxVal = val
                    maxStr = s.contains("mm") ? s : "\(s) mm"
                }
            }
        }
        
        guard let maxV = maxVal else {
            return (sizes.first ?? "N/A", nil, "Calculus", LiquidGlassTheme.softAzure)
        }
        
        if maxV >= 20 {
            return (maxStr, maxV, "Large / Staghorn", LiquidGlassTheme.coralDanger)
        } else if maxV >= 10 {
            return (maxStr, maxV, "Substantial (≥10mm)", LiquidGlassTheme.amberWarning)
        } else if maxV >= 5 {
            return (maxStr, maxV, "Moderate (5–10mm)", LiquidGlassTheme.softAzure)
        } else {
            return (maxStr, maxV, "Passable (<5mm)", LiquidGlassTheme.emeraldSuccess)
        }
    }

    // MARK: - Networking
    private func fetchPatientName() {
        guard !pid.isEmpty else { return }
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/pprofile.php?pid=\(pid)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            
            if let status = json["status"] as? String, status == "success",
               let dataDict = json["data"] as? [String: Any] {
                DispatchQueue.main.async {
                    self.patientName = dataDict["name"] as? String ?? ""
                }
            }
        }.resume()
    }

    private func checkForDoctorReview() {
        guard !pid.isEmpty else { return }
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/report.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["pid": pid]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                struct ReportItem: Codable {
                    let diagnosis_notes: String?
                    let created_at: String?
                }
                
                struct ReportCheck: Codable {
                    let history: [ReportItem]?
                }
                
                let decoded = try JSONDecoder().decode(ReportCheck.self, from: data)
                
                DispatchQueue.main.async {
                    if let reports = decoded.history {
                        for report in reports {
                            if let notes = report.diagnosis_notes,
                               !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                let notification = DoctorReviewNotification(
                                    message: "Your latest kidney stone analysis has been reviewed by a doctor.",
                                    timestamp: Date()
                                )
                                
                                if !self.doctorReviewNotifications.contains(where: { $0.message == notification.message }) {
                                    self.doctorReviewNotifications.append(notification)
                                    self.hasSeenNotification = true
                                }
                                return
                            }
                        }
                    }
                }
            } catch {
                print("Error checking doctor review: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func fetchLastReport() {
        guard !pid.isEmpty else {
            errorMessage = "Patient ID not found"
            return
        }
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/last_report.php") else {
            errorMessage = "Invalid API URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["pid": pid]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        isLoadingReport = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { DispatchQueue.main.async { isLoadingReport = false } }
            
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Network error"
                    print("API error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(LastReportResponse.self, from: data)
                DispatchQueue.main.async {
                    if decoded.success, let report = decoded.last_report {
                        self.lastReport = report
                        self.errorMessage = nil
                    } else {
                        self.errorMessage = "No reports available"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to parse report"
                }
            }
        }.resume()
    }
}

// --------------------------------------------------
// MARK: - PATIENT METRIC TILE
// --------------------------------------------------
struct PatientMetricTile: View {
    let title: String
    let value: String
    let subtext: String
    let icon: String
    let accentColor: Color

    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(isDark ? 0.24 : 0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(accentColor)
                }

                Spacer()

                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(isDark ? Color.white.opacity(0.6) : LiquidGlassTheme.textMuted)
                    .lineLimit(1)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isDark ? .white : LiquidGlassTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(subtext)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(accentColor)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isDark ? Color.white.opacity(0.06) : Color(hex: "F8FAFC"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            isDark ? Color.white.opacity(0.10) : Color(hex: "E2E8F0"),
                            lineWidth: 1
                        )
                )
        )
    }
}

// --------------------------------------------------
// MARK: - PATIENT STONE ROW
// --------------------------------------------------
struct PatientStoneRow: View {
    let stone: ParsedStone
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        HStack(spacing: 12) {
            // Index badge
            Text("#\(stone.index)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(LiquidGlassTheme.primaryTeal)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(LiquidGlassTheme.primaryTeal.opacity(isDark ? 0.25 : 0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(stone.sizeText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isDark ? .white : LiquidGlassTheme.textPrimary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(stone.location)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isDark ? Color.white.opacity(0.7) : LiquidGlassTheme.textSecondary)
                }

                Text(stone.severityLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(stone.severityColor)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 3)
                .fill(stone.severityColor)
                .frame(width: 4, height: 26)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isDark ? Color.white.opacity(0.03) : Color.white)
        )
    }
}

// --------------------------------------------------
// MARK: - GUIDANCE ROW
// --------------------------------------------------
struct GuidanceRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isDark ? .white : LiquidGlassTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isDark ? Color.white.opacity(0.7) : LiquidGlassTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// --------------------------------------------------
// MARK: - COMPATIBILITY HELPERS
// --------------------------------------------------
struct EnhancedDashboardCard: View {
    var title: String
    var icon: String
    var color: Color = .teal
    @Binding var showCard: Bool

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 85, height: 85)
                    .scaleEffect(showCard ? 1 : 0.8)
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 75, height: 75)
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            }

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .shadow(color: color.opacity(0.35), radius: 20, x: 0, y: 12)
    }
}

struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct EnhancedReportRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let index: Int

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4, height: 30)
        }
        .padding(.vertical, 4)
    }
}

