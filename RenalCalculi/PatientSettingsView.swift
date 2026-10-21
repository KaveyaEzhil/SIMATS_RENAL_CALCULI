import SwiftUI

struct PatientSettingsView: View {
    let pid: String
    
    @AppStorage("patientPID") private var patientPID: String = ""
    @AppStorage("patientName") private var patientName: String = ""
    @AppStorage("patientEmail") private var patientEmail: String = ""
    @AppStorage("patientPhone") private var patientPhone: String = ""
    @AppStorage("patientAge") private var patientAge: String = ""
    @AppStorage("patientGender") private var patientGender: String = ""
    @AppStorage("patientAddress") private var patientAddress: String = ""
    @AppStorage("patientWork") private var patientWork: String = ""
    
    @AppStorage("doctorLogin") var doctorLogin: Bool = false
    @AppStorage("patientLogin") var patientLogin: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @State private var showLogoutAlert = false
    @State private var navigateToUserSelection = false
    
    var body: some View {
        ZStack {
            LiquidAmbientBackground()
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    headerCard
                    
                    VStack(spacing: 18) {
                        generalSettingsSection
                        accountSection
                        aboutButton
                        logoutSection
                    }
                    .padding(.horizontal, 16)
                    
                    footerSection
                    
                    // Bottom clearance to ensure no overlap with floating tab bar
                    Color.clear.frame(height: 110)
                }
                .padding(.top, 8)
            }
            
            NavigationLink(
                destination: LogoScreen(),
                isActive: $navigateToUserSelection
            ) {
                EmptyView()
            }
            .hidden()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                handleLogout()
            }
        } message: {
            Text("Are you sure you want to logout? You'll need to log in again to access your account.")
        }
    }
    
    // MARK: - Subviews
    private var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.teal.opacity(0.2), Color.blue.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.teal, .teal.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 6) {
                Text(patientName.isEmpty ? "Patient" : patientName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isDarkMode ? .white : LiquidGlassTheme.textPrimary)
                
                Text(patientEmail.isEmpty ? "No email" : patientEmail)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isDarkMode ? Color.white.opacity(0.65) : .secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(isDarkMode ? Color(hex: "0F172A").opacity(0.75) : Color.white.opacity(0.92))
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: isDarkMode ? [
                            Color.white.opacity(0.25),
                            Color(hex: "38BDF8").opacity(0.20),
                            Color.white.opacity(0.05)
                        ] : [
                            Color.white,
                            Color(hex: "38BDF8").opacity(0.35),
                            Color.white.opacity(0.60)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: isDarkMode ? Color.black.opacity(0.35) : Color(hex: "0F172A").opacity(0.06), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 16)
    }

    private var generalSettingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(isDarkMode ? 0.22 : 0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "gear")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.teal)
                }
                
                Text("General Settings")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDarkMode ? .white : LiquidGlassTheme.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            SettingsRow(
                icon: "number.circle.fill",
                label: "Patient ID",
                value: pid,
                color: .teal
            )
            
            Divider()
                .background(isDarkMode ? Color.white.opacity(0.12) : Color.gray.opacity(0.15))
            
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isDarkMode ? Color(hex: "8B5CF6").opacity(0.25) : Color(hex: "F59E0B").opacity(0.22))
                        .frame(width: 36, height: 36)
                    Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isDarkMode ? Color(hex: "A78BFA") : Color(hex: "F59E0B"))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dark Mode")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isDarkMode ? .white : LiquidGlassTheme.textPrimary)
                        .lineLimit(1)
                    Text(isDarkMode ? "Dark Clinical Mode" : "Light Hospital Mode")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isDarkMode ? Color.white.opacity(0.65) : .secondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 8)
                
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
            .padding(.vertical, 2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isDarkMode ? Color(hex: "0F172A").opacity(0.75) : Color.white.opacity(0.92))
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: isDarkMode ? [
                            Color.white.opacity(0.20),
                            Color(hex: "38BDF8").opacity(0.25),
                            Color.white.opacity(0.05)
                        ] : [
                            Color.white,
                            Color(hex: "38BDF8").opacity(0.30),
                            Color.white.opacity(0.60)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: isDarkMode ? Color.black.opacity(0.35) : Color(hex: "0F172A").opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(isDarkMode ? 0.22 : 0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                Text("Account Information")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDarkMode ? .white : LiquidGlassTheme.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 10) {
                SettingsRow(
                    icon: "person.text.rectangle.fill",
                    label: "Name",
                    value: patientName.isEmpty ? "Not set" : patientName,
                    color: .blue
                )
                
                Divider()
                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.gray.opacity(0.12))
                
                SettingsRow(
                    icon: "envelope.fill",
                    label: "Email",
                    value: patientEmail.isEmpty ? "Not set" : patientEmail,
                    color: .blue
                )
                
                if !patientPhone.isEmpty {
                    Divider()
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.gray.opacity(0.12))
                    
                    SettingsRow(
                        icon: "phone.fill",
                        label: "Phone",
                        value: patientPhone,
                        color: .blue
                    )
                }
                
                if !patientAge.isEmpty {
                    Divider()
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.gray.opacity(0.12))
                    
                    SettingsRow(
                        icon: "calendar.badge.plus",
                        label: "Age",
                        value: patientAge,
                        color: .blue
                    )
                }
            }
            .padding(14)
            .background(isDarkMode ? Color.white.opacity(0.04) : Color(hex: "F8FAFC"))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.04), lineWidth: 1)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isDarkMode ? Color(hex: "0F172A").opacity(0.75) : Color.white.opacity(0.92))
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: isDarkMode ? [
                            Color.white.opacity(0.20),
                            Color(hex: "38BDF8").opacity(0.25),
                            Color.white.opacity(0.05)
                        ] : [
                            Color.white,
                            Color(hex: "38BDF8").opacity(0.30),
                            Color.white.opacity(0.60)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: isDarkMode ? Color.black.opacity(0.35) : Color(hex: "0F172A").opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private var aboutButton: some View {
        NavigationLink(destination: AboutNephrolithView()) {
            HStack(spacing: 16) {
                // Icon Container with Gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.teal.opacity(isDarkMode ? 0.30 : 0.20), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: .teal.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.teal, .blue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .teal.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("About Renal Calculi")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isDarkMode ? .white : LiquidGlassTheme.textPrimary)
                    
                    Text("App Information & Details")
                        .font(.system(size: 14))
                        .foregroundColor(isDarkMode ? Color.white.opacity(0.65) : .secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isDarkMode ? Color.white.opacity(0.35) : .gray.opacity(0.7))
                    .padding(.trailing, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isDarkMode ? Color(hex: "0F172A").opacity(0.75) : Color.white.opacity(0.92))
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: isDarkMode ? [
                                Color.white.opacity(0.20),
                                Color.teal.opacity(0.25),
                                Color.white.opacity(0.05)
                            ] : [
                                Color.white,
                                Color.teal.opacity(0.30),
                                Color.white.opacity(0.60)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: isDarkMode ? Color.black.opacity(0.35) : Color(hex: "0F172A").opacity(0.05), radius: 10, x: 0, y: 4)
            .contentShape(Rectangle())
        }
    }

    private var logoutSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(isDarkMode ? 0.25 : 0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                }
                
                Text("Account Actions")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDarkMode ? .white : LiquidGlassTheme.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            Button(action: { showLogoutAlert = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.to.line")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text("Logout")
                        .font(.system(size: 15, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    LinearGradient(
                        colors: isDarkMode ? [Color.red.opacity(0.22), Color.red.opacity(0.12)] : [Color.red.opacity(0.10), Color.red.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.red)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isDarkMode ? Color(hex: "450A0A").opacity(0.35) : Color(hex: "FEF2F2"))
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.red.opacity(isDarkMode ? 0.35 : 0.20), lineWidth: 1.2)
        )
        .shadow(color: isDarkMode ? Color.black.opacity(0.35) : Color.red.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private var footerSection: some View {
        VStack(spacing: 6) {
            Text("Version 1.0.0")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isDarkMode ? Color.white.opacity(0.50) : .secondary)
            
            Text("© 2025 Renal Calculi.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isDarkMode ? Color.white.opacity(0.35) : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    func handleLogout() {
        print("🚪 Logging out - PID: \(pid)")
        patientPID = ""
        patientName = ""
        patientEmail = ""
        patientPhone = ""
        patientAge = ""
        patientGender = ""
        patientAddress = ""
        patientWork = ""
        print("🗑️ All data cleared")
        doctorLogin = false
        patientLogin = false
        navigateToUserSelection = true
    }
    
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(isDark ? 0.20 : 0.12))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isDark ? Color.white.opacity(0.65) : Color(hex: "64748B"))
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isDark ? .white : LiquidGlassTheme.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        PatientSettingsView(pid: "PID001")
    }
}
