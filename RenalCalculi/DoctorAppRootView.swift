import SwiftUI

// MARK: - Main App Root with DID Persistence & Helper Functions

struct DoctorAppRootView: View {
    @StateObject var profile = DoctorProfile()
    @StateObject var patientsStore = PatientsStore()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    // ✅ PERSISTENT DID - Survives app restarts until logout
    @AppStorage("doctorDID") private var doctorDID: String = ""
    @AppStorage("doctorName") private var doctorName: String = ""
    @AppStorage("doctorEmail") private var doctorEmail: String = ""
    @AppStorage("doctorPhone") private var doctorPhone: String = ""
    @AppStorage("doctorSpecialization") private var doctorSpecialization: String = ""
    @AppStorage("doctorHospital") private var doctorHospital: String = ""
    @AppStorage("doctorGender") private var doctorGender: String = ""
    
    @State private var selectedTab = 0
    @State private var showSidebar = false
    @State private var navigateToUserSelection = false
    @State private var isAppReady = false
    
    var body: some View {
        ZStack {
            if !isAppReady {
                // ✅ INITIALIZATION CHECK
                LiquidGlassLoadingView(
                    title: "Physician Workspace",
                    subtitle: "Synchronizing Clinical Cases & Diagnostic Queue...",
                    badgeText: "CLINICAL PORTAL ACTIVE",
                    icon: "stethoscope"
                )
                .onAppear {
                    initializeApp()
                }
                
            } else if navigateToUserSelection {
                // ✅ NAVIGATE TO USER SELECTION AFTER LOGOUT
                UserSelectionView()
                
            } else {
                ZStack(alignment: .bottom) {
                    // Main Content - Instant High-Performance Tab Switching
                    Group {
                        switch selectedTab {
                        case 0:
                            DoctorDashboardView(showSidebar: $showSidebar, selectedTab: $selectedTab)
                                .environmentObject(profile)
                                .environmentObject(patientsStore)
                                .navigationBarHidden(true)
                        case 1:
                            AllCasesView()
                                .environmentObject(profile)
                                .navigationBarHidden(true)
                        case 2:
                            DoctorProfileView()
                                .environmentObject(profile)
                                .navigationBarHidden(true)
                        default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // ✨ Floating Liquid Glass Navigation Bar
                    LiquidBar(selectedTab: $selectedTab)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 12)
                }
                
                .preferredColorScheme(isDarkMode ? .dark : .light)
                
                // Twitter-style Sidebar Overlay
                if showSidebar {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showSidebar = false
                            }
                        }
                    
                    HStack {
                        DoctorSidebarView(
                            showSidebar: $showSidebar,
                            navigateToUserSelection: $navigateToUserSelection,
                            onLogout: handleLogout
                        )
                        .environmentObject(profile)
                        .frame(width: min(UIScreen.main.bounds.width * 0.82, 310))
                        .background(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.25), radius: 15, x: 5, y: 0)
                        .transition(.move(edge: .leading))
                        
                        Spacer()
                    }
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    // ✅ INITIALIZATION - Load doctor data from AppStorage
    func initializeApp() {
        print("🔑 Initializing Doctor Portal...")
        if !doctorDID.isEmpty {
            print("✅ Found existing session for: \(doctorDID)")
            profile.did = doctorDID
            profile.name = doctorName
            profile.email = doctorEmail
            profile.phone = doctorPhone
            profile.specialization = doctorSpecialization
            profile.hospital = doctorHospital
            profile.gender = doctorGender
            patientsStore.currentDoctorDID = doctorDID
            print("📱 Doctor data restored: \(profile.name) (\(doctorDID))")
        } else {
            print("⚠️ No active session found")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAppReady = true
            }
        }
    }
    
    // ✅ LOGOUT - Clear all AppStorage values FIRST, then navigate
    func handleLogout() {
        print("🚪 Logging out doctor: \(doctorDID)")
        doctorDID = ""
        doctorName = ""
        doctorEmail = ""
        doctorPhone = ""
        doctorSpecialization = ""
        doctorHospital = ""
        doctorGender = ""
        profile.did = ""
        profile.name = ""
        profile.email = ""
        profile.phone = ""
        profile.specialization = ""
        profile.hospital = ""
        profile.gender = ""
        patientsStore.selectedPatients = []
        patientsStore.currentDoctorDID = ""
        print("🗑️ All user data cleared")
        print("🔄 Navigating to User Selection...")
        withAnimation {
            navigateToUserSelection = true
        }
    }
}

// MARK: - Updated Liquid Glass Floating Navigation Bar (VisionOS Optics & Snappy Switching)

struct DoctorTabItem: Identifiable {
    let id: Int
    let icon: String
    let filledIcon: String
    let title: String
    let tag: Int
}

struct LiquidBar: View {
    @Binding var selectedTab: Int
    @Namespace private var barNamespace
    @Environment(\.colorScheme) var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    let tabs: [DoctorTabItem] = [
        DoctorTabItem(id: 0, icon: "square.grid.2x2", filledIcon: "square.grid.2x2.fill", title: "Dashboard", tag: 0),
        DoctorTabItem(id: 1, icon: "person.2", filledIcon: "person.2.fill", title: "Patients", tag: 1),
        DoctorTabItem(id: 2, icon: "person.crop.circle", filledIcon: "person.crop.circle.fill", title: "Profile", tag: 2)
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs) { tab in
                let isSelected = selectedTab == tab.tag
                
                Button {
                    if selectedTab != tab.tag {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                            selectedTab = tab.tag
                        }
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: isSelected ? tab.filledIcon : tab.icon)
                            .font(.system(size: isSelected ? 19 : 18, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(
                                isSelected
                                    ? AnyShapeStyle(LiquidGlassTheme.gradientPrimary)
                                    : AnyShapeStyle(isDark ? Color.white.opacity(0.65) : Color.secondary.opacity(0.8))
                            )
                            .scaleEffect(isSelected ? 1.08 : 1.0)
                        
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
                                    .matchedGeometryEffect(id: "DOCTOR_ACTIVE_TAB_PILL", in: barNamespace)
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

// MARK: - Preview

#Preview {
    DoctorAppRootView()
}
