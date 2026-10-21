import SwiftUI
import WebKit

// MARK: - WEBVIEW
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Custom Navigation Link Style
struct SidebarNavigationLinkStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
    }
}

// MARK: - Doctor Sidebar Button Component (Liquid Glass)
struct SidebarButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let showChevron: Bool
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String? = nil, showChevron: Bool = true, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "06B6D4").opacity(0.18), Color(hex: "3B82F6").opacity(0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "38BDF8"), Color(hex: "06B6D4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary.opacity(0.6))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
}

// ------------------------------------------------------
// MARK: DOCTOR SIDEBAR VIEW (Liquid Glass)
// ------------------------------------------------------

struct DoctorSidebarView: View {
    @EnvironmentObject var profile: DoctorProfile
    @Binding var showSidebar: Bool
    @Binding var navigateToUserSelection: Bool
    
    // MARK: Full-screen Navigation States
    @State private var showProfile = false
    @State private var showSettings = false
    @State private var showHelp = false
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showAbout = false
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("doctorLogin") var doctorLogin: Bool = false
    @AppStorage("patientLogin") var patientLogin: Bool = false
    
    @State private var showLogoutAlert = false
    var onLogout: (() -> Void)?
    
    // Animation states
    @State private var animateHeader = false
    
    var body: some View {
        ZStack {
            // Frosted ambient backdrop
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // HEADER
                profileHeader
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
                
                ScrollView {
                    VStack(spacing: 12) {
                        // NAVIGATION ITEMS
                        VStack(spacing: 10) {
                            SidebarButton(
                                icon: "person.crop.square.fill",
                                title: "Doctor Profile",
                                subtitle: "Clinical ID & Practice Details"
                            ) {
                                showProfile = true
                            }
                            
                            SidebarButton(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                subtitle: "Protocol assistance & guide"
                            ) {
                                showHelp = true
                            }
                            
                            SidebarButton(
                                icon: "shield.fill",
                                title: "Privacy Policy",
                                subtitle: "HIPAA compliance standards"
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
                                subtitle: "Model telemetry & info"
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
                        
                        // LOGOUT BUTTON
                        Button(action: { showLogoutAlert = true }) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "power")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: "EF4444"))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Physician Sign Out")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color(hex: "EF4444"))
                                    
                                    Text("Terminate current session")
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
                            Text("Renal Calculi AI Clinical Workstation")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("v1.0 • High-Precision Renal Vision")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        
        // LOGOUT ALERT
        .alert("Confirm Doctor Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) { performLogout() }
        } message: {
            Text("Are you sure you want to log out of your clinical session? Unsaved notes will require resubmission.")
        }
        
        // FULL SCREEN COVERS
        .fullScreenCover(isPresented: $showProfile) {
            NavigationStack {
                DoctorProfileView()
            }
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
                AboutNephrolithView2()
            }
        }
    }
    
    // ------------------------------------------------------
    // MARK: ENHANCED PROFILE HEADER (Liquid Glass)
    // ------------------------------------------------------
    
    var profileHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                // Profile Avatar with Glow
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "0EA5E9"), Color(hex: "06B6D4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .shadow(color: Color(hex: "06B6D4").opacity(0.3), radius: 6, y: 3)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(profile.name.isEmpty ? "Doctor Portal" : profile.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(profile.email.isEmpty ? "Nephrology Specialist" : profile.email)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Specialization & Clinical Presence Pill
            HStack(spacing: 8) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "06B6D4"))
                
                Text(profile.specialization.isEmpty ? "Nephrology" : profile.specialization)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: "10B981"))
                        .frame(width: 6, height: 6)
                        .shadow(color: Color(hex: "10B981"), radius: 3)
                    
                    Text("Online")
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
    
    // ------------------------------------------------------
    // MARK: LOGOUT (Preserved Logic)
    // ------------------------------------------------------
    
    func performLogout() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showSidebar = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            doctorLogin = false
            patientLogin = false
            onLogout?()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                navigateToUserSelection = true
            }
        }
    }
}
