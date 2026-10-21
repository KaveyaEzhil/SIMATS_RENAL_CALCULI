import SwiftUI

// MARK: - Doctor Login View
struct DoctorLoginResponse: Decodable {
    let status: String
    let message: String
    let data: DoctorData?
}

struct DoctorData: Decodable {
    let did: String
    let name: String
    let email: String
    let specialization: String
    let hospital: String
    let phone: String
    let gender: String
    let created_at: String
}

struct DoctorLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToDashboard = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showPassword = false
    @State private var animateGradient = false
    enum Field {
        case email, password
    }
    @FocusState private var focusedField: Field?
    
    // Animation states
    @State private var headerScale: CGFloat = 0.85
    @State private var headerOpacity: Double = 0
    @State private var formOffset: CGFloat = 25
    @State private var formOpacity: Double = 0
    
    @AppStorage("doctorDID") var doctorDID: String = ""
    @AppStorage("doctorName") var doctorName: String = ""
    @AppStorage("doctorEmail") var doctorEmail: String = ""
    @AppStorage("doctorPhone") var doctorPhone: String = ""
    @AppStorage("doctorSpecialization") var doctorSpecialization: String = ""
    @AppStorage("doctorHospital") var doctorHospital: String = ""
    @AppStorage("doctorGender") var doctorGender: String = ""
    @AppStorage("doctorLogin") var doctorLogin: Bool = false
    
    var body: some View {
        ZStack {
            // MARK: - Liquid Glass Ambient Canvas
            LiquidAmbientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // MARK: - Animated Doctor Portal Emblem
                    VStack(spacing: 16) {
                        ZStack {
                            // Specular ambient glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            LiquidGlassTheme.vibrantCyan.opacity(0.35),
                                            LiquidGlassTheme.primaryTeal.opacity(0.12),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 75
                                    )
                                )
                                .frame(width: 150, height: 150)
                                .blur(radius: 12)
                                .scaleEffect(isLoading ? 1.15 : 1.0)
                                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isLoading)
                            
                            // Frosted glass circular medallion
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 104, height: 104)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.9),
                                                    Color.white.opacity(0.3),
                                                    LiquidGlassTheme.vibrantCyan.opacity(0.5)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.25), radius: 18, x: 0, y: 8)
                            
                            // Medical caduceus / stethoscope icon
                            Image(systemName: "stethoscope")
                                .font(.system(size: 46, weight: .semibold))
                                .foregroundStyle(LiquidGlassTheme.gradientPrimary)
                                .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .scaleEffect(headerScale)
                        .opacity(headerOpacity)
                        .padding(.top, 40)
                        
                        VStack(spacing: 6) {
                            LiquidGlassPill(
                                title: "CLINICAL PORTAL",
                                icon: "cross.case.fill",
                                color: LiquidGlassTheme.primaryTeal,
                                isGlowing: true
                            )
                            
                            Text("Physician Workspace")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(LiquidGlassTheme.textPrimary)
                            
                            Text("Review Renal Calculus Diagnostics & Patient Records")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(LiquidGlassTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .opacity(headerOpacity)
                    }
                    
                    // MARK: - Liquid Glass Authentication Card
                    VStack(spacing: 20) {
                        // Email / Phone Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PHYSICIAN IDENTIFIER")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(LiquidGlassTheme.textSecondary)
                                .tracking(0.5)
                                .padding(.horizontal, 4)
                            
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(focusedField == .email ? LiquidGlassTheme.primaryTeal.opacity(0.20) : Color(hex: "0284C7").opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(focusedField == .email ? LiquidGlassTheme.vibrantCyan : LiquidGlassTheme.primaryTeal)
                                }
                                
                                TextField("", text: $email)
                                    .placeholder(when: email.isEmpty) {
                                        Text("Email or registered phone")
                                            .foregroundColor(LiquidGlassTheme.textMuted)
                                    }
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(LiquidGlassTheme.textPrimary)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .focused($focusedField, equals: .email)
                                
                                if !email.isEmpty {
                                    Button {
                                        email = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(LiquidGlassTheme.textMuted)
                                            .font(.system(size: 15))
                                    }
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(
                                        focusedField == .email
                                            ? LiquidGlassTheme.vibrantCyan
                                            : LiquidGlassTheme.inputBorder,
                                        lineWidth: focusedField == .email ? 1.8 : 1.2
                                    )
                            )
                            .shadow(
                                color: focusedField == .email ? Color(hex: "0284C7").opacity(0.22) : Color.black.opacity(0.03),
                                radius: 6,
                                x: 0,
                                y: 2
                            )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SECURITY CREDENTIAL")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(LiquidGlassTheme.textSecondary)
                                .tracking(0.5)
                                .padding(.horizontal, 4)
                            
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(focusedField == .password ? LiquidGlassTheme.primaryTeal.opacity(0.20) : Color(hex: "0284C7").opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(focusedField == .password ? LiquidGlassTheme.vibrantCyan : LiquidGlassTheme.primaryTeal)
                                }
                                
                                if showPassword {
                                    TextField("", text: $password)
                                        .placeholder(when: password.isEmpty) {
                                            Text("Account password")
                                                .foregroundColor(LiquidGlassTheme.textMuted)
                                        }
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(LiquidGlassTheme.textPrimary)
                                        .focused($focusedField, equals: .password)
                                } else {
                                    SecureField("", text: $password)
                                        .placeholder(when: password.isEmpty) {
                                            Text("Account password")
                                                .foregroundColor(LiquidGlassTheme.textMuted)
                                        }
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(LiquidGlassTheme.textPrimary)
                                        .focused($focusedField, equals: .password)
                                }
                                
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        showPassword.toggle()
                                    }
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(LiquidGlassTheme.textMuted)
                                        .frame(width: 30, height: 30)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(
                                        focusedField == .password
                                            ? LiquidGlassTheme.vibrantCyan
                                            : LiquidGlassTheme.inputBorder,
                                        lineWidth: focusedField == .password ? 1.8 : 1.2
                                    )
                            )
                            .shadow(
                                color: focusedField == .password ? Color(hex: "0284C7").opacity(0.22) : Color.black.opacity(0.03),
                                radius: 6,
                                x: 0,
                                y: 2
                            )
                        }
                        
                        // Forgot Password Link
                        HStack {
                            Spacer()
                            NavigationLink(destination: DoctorForgotPasswordView()) {
                                HStack(spacing: 5) {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Forgot Password?")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(LiquidGlassTheme.primaryTeal)
                            }
                        }
                        
                        // Clinical Disclaimer Banner (Liquid Glass)
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LiquidGlassTheme.amberWarning.opacity(0.20))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "exclamationmark.shield.fill")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(LiquidGlassTheme.amberWarning)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Research & Academic System")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "92400E"))
                                
                                Text("Academic clinical project. Not a certified standalone device. Always verify clinical findings before patient intervention.")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "78350F"))
                                    .lineSpacing(2)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(hex: "FFFBEB"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color(hex: "FDE68A"), lineWidth: 1.2)
                        )
                        
                        // Login Action Button
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            withAnimation {
                                handleLogin()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                } else {
                                    Image(systemName: "stethoscope.circle.fill")
                                        .font(.system(size: 18))
                                }
                                
                                Text(isLoading ? "Authenticating..." : "Login to Doctor Portal")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                
                                if !isLoading {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                ZStack {
                                    if email.isEmpty || password.isEmpty || isLoading {
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "0284C7").opacity(0.38),
                                                Color(hex: "06B6D4").opacity(0.28)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "0284C7"),
                                                Color(hex: "0EA5E9"),
                                                Color(hex: "06B6D4")
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                    
                                    // Gloss specular sheen
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(
                                            (email.isEmpty || password.isEmpty || isLoading)
                                                ? Color(hex: "0284C7").opacity(0.40)
                                                : Color.white.opacity(0.55),
                                            lineWidth: 1.2
                                        )
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(
                                color: (email.isEmpty || password.isEmpty || isLoading)
                                    ? Color.clear
                                    : Color(hex: "0284C7").opacity(0.40),
                                radius: 14,
                                x: 0,
                                y: 6
                            )
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        .buttonStyle(LiquidGlassButtonStyle())
                    }
                    .padding(22)
                    .liquidGlass(cornerRadius: 24, shadowRadius: 22)
                    .padding(.horizontal, 18)
                    .offset(y: formOffset)
                    .opacity(formOpacity)
                    
                    // MARK: - Registration Footer
                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color(hex: "CBD5E1"))
                                .frame(height: 1)
                            Text("NEW PHYSICIAN?")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(LiquidGlassTheme.textMuted)
                                .tracking(1)
                            Rectangle()
                                .fill(Color(hex: "CBD5E1"))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 40)
                        
                        NavigationLink(destination: DoctorSignupView()) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Register Physician Credentials")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(LiquidGlassTheme.primaryTeal)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.92))
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white,
                                                LiquidGlassTheme.primaryTeal.opacity(0.45)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.2
                                    )
                            )
                            .shadow(color: Color(hex: "0F172A").opacity(0.08), radius: 8, x: 0, y: 3)
                        }
                    }
                    .padding(.bottom, 36)
                    .opacity(formOpacity)
                }
            }
            
            NavigationLink(destination: DoctorAppRootView(), isActive: $navigateToDashboard) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .alert("Login Failed", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                headerScale = 1.0
                headerOpacity = 1.0
            }
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.15)) {
                formOffset = 0
                formOpacity = 1.0
            }
        }
    }

    func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }

        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/dlogin.php") else {
            alertMessage = "Invalid server URL"
            showAlert = true
            return
        }

        isLoading = true

        let isEmail = email.contains("@")
        var body: [String: Any] = ["password": password]

        if isEmail {
            body["email"] = email
        } else {
            body["phone"] = email
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            isLoading = false
            alertMessage = "Failed to create request"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    alertMessage = "Network error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                guard let data = data else {
                    alertMessage = "No data from server"
                    showAlert = true
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let loginResponse = try decoder.decode(DoctorLoginResponse.self, from: data)

                    if loginResponse.status == "success", let doctorData = loginResponse.data {
                        self.doctorDID = doctorData.did
                        self.doctorName = doctorData.name
                        self.doctorEmail = doctorData.email
                        self.doctorPhone = doctorData.phone
                        self.doctorSpecialization = doctorData.specialization
                        self.doctorHospital = doctorData.hospital
                        self.doctorGender = doctorData.gender
                        self.doctorLogin = true
                        print("✅ Doctor logged in: \(doctorData.did)")
                        navigateToDashboard = true
                    } else {
                        alertMessage = loginResponse.message
                        showAlert = true
                    }
                } catch {
                    alertMessage = "Invalid response from server"
                    showAlert = true
                }
            }
        }.resume()
    }
}

// MARK: - PREVIEW
struct DoctorLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DoctorLoginView()
        }
    }
}
