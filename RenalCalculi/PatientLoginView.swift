import SwiftUI

struct PatientLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var loginError = ""
    @State private var navigate = false
    @State private var retrievedPID = ""
    
    enum Field: Hashable {
        case email, password
    }
    @FocusState private var focusedField: Field?
    
    // Animation states
    @State private var headerScale: CGFloat = 0.85
    @State private var headerOpacity: Double = 0
    @State private var formOffset: CGFloat = 25
    @State private var formOpacity: Double = 0
    
    // Store user session
    @AppStorage("patientPID") var patientPID: String = ""
    @AppStorage("patientName") var patientName: String = ""
    @AppStorage("patientEmail") var patientEmail: String = ""
    @AppStorage("patientPhone") var patientPhone: String = ""
    @AppStorage("patientAge") var patientAge: String = ""
    @AppStorage("patientGender") var patientGender: String = ""
    @AppStorage("patientAddress") var patientAddress: String = ""
    @AppStorage("patientWork") var patientWork: String = ""
    @AppStorage("patientLogin") var patientLogin: Bool = false
    
    @AppStorage("medicalDisclaimerAccepted")
    private var medicalDisclaimerAccepted: Bool = false
    
    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        medicalDisclaimerAccepted &&
        !isLoading
    }
    
    var body: some View {
        ZStack {
            // MARK: - Liquid Glass Ambient Canvas
            LiquidAmbientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // MARK: - Animated Patient Portal Emblem
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
                                                    Color.white.opacity(0.95),
                                                    Color.white.opacity(0.30),
                                                    LiquidGlassTheme.vibrantCyan.opacity(0.50)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.25), radius: 18, x: 0, y: 8)
                            
                            // Patient user profile icon
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 54, weight: .medium))
                                .foregroundStyle(LiquidGlassTheme.gradientPrimary)
                                .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.30), radius: 6, x: 0, y: 3)
                        }
                        .scaleEffect(headerScale)
                        .opacity(headerOpacity)
                        .padding(.top, 40)
                        
                        VStack(spacing: 6) {
                            LiquidGlassPill(
                                title: "PATIENT PORTAL",
                                icon: "heart.fill",
                                color: LiquidGlassTheme.primaryTeal,
                                isGlowing: true
                            )
                            
                            Text("Welcome Back")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(LiquidGlassTheme.textPrimary)
                            
                            Text("Sign in to access your renal diagnostics & health records")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(LiquidGlassTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .opacity(headerOpacity)
                    }
                    
                    // MARK: - Liquid Glass Authentication Card
                    VStack(spacing: 20) {
                        // Patient Identifier Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PATIENT IDENTIFIER")
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
                            NavigationLink(destination: PatientForgotPasswordView()) {
                                HStack(spacing: 5) {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Forgot Password?")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(LiquidGlassTheme.primaryTeal)
                            }
                        }
                        
                        // Error Message Banner (if present)
                        if !loginError.isEmpty {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "exclamationmark.octagon.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "DC2626"))
                                
                                Text(loginError)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "991B1B"))
                                    .lineSpacing(2)
                                
                                Spacer(minLength: 0)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(hex: "FEF2F2"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color(hex: "FCA5A5"), lineWidth: 1.2)
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Medical & Academic Disclaimer Banner
                        VStack(alignment: .leading, spacing: 10) {
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
                                    Text("Medical & Academic Disclaimer")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "92400E"))
                                    
                                    Text("This app is an academic research project developed for educational purposes. It is not a certified medical device and does not provide clinical diagnosis. Always consult healthcare professionals for medical decisions.")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "78350F"))
                                        .lineSpacing(2)
                                }
                            }
                            
                            Divider()
                                .background(Color(hex: "FDE68A"))
                            
                            Toggle(isOn: $medicalDisclaimerAccepted) {
                                Text("I understand and accept disclaimer")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "92400E"))
                            }
                            .toggleStyle(SwitchToggleStyle(tint: LiquidGlassTheme.primaryTeal))
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
                                loginUser()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 18))
                                }
                                
                                Text(isLoading ? "Logging in..." : "Login to Patient Portal")
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
                                    if !isFormValid {
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
                                            !isFormValid
                                                ? Color(hex: "0284C7").opacity(0.40)
                                                : Color.white.opacity(0.55),
                                            lineWidth: 1.2
                                        )
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(
                                color: !isFormValid
                                    ? Color.clear
                                    : Color(hex: "0284C7").opacity(0.40),
                                radius: 14,
                                x: 0,
                                y: 6
                            )
                        }
                        .disabled(!isFormValid)
                        .buttonStyle(LiquidGlassButtonStyle())
                        
                        NavigationLink(
                            destination: PatientAppRootView(),
                            isActive: $navigate
                        ) {
                            EmptyView()
                        }
                        .hidden()
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
                            Text("NEW PATIENT?")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(LiquidGlassTheme.textMuted)
                                .tracking(1)
                            Rectangle()
                                .fill(Color(hex: "CBD5E1"))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 40)
                        
                        NavigationLink(destination: PatientSignupView()) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Create Patient Account")
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
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
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
    
    // MARK: - Login API Call
    func loginUser() {
        loginError = ""
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            loginError = "Please enter email or phone number"
            return
        }
        
        guard !password.isEmpty else {
            loginError = "Please enter password"
            return
        }
        
        guard medicalDisclaimerAccepted else {
            loginError = "Please accept the medical disclaimer to continue"
            return
        }
        
        isLoading = true
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/plogin.php") else {
            loginError = "Invalid server URL"
            isLoading = false
            return
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let body: [String: Any] = [
            "email": trimmedEmail,
            "phone": trimmedEmail,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            loginError = "Invalid request data"
            isLoading = false
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
                    loginError = "Network error: \(error.localizedDescription)"
                    print("❌ Network error:", error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    loginError = "No response from server"
                    return
                }
                
                if let raw = String(data: data, encoding: .utf8) {
                    print("🔥 Server Response:", raw)
                }
                
                do {
                    let loginResponse = try JSONDecoder().decode(LoginMdoel.self, from: data)
                    
                    print("🟢 Decoded response:", loginResponse)
                    
                    if loginResponse.status.lowercased() == "success" {
                        
                        let user = loginResponse.data
                        
                        patientPID = user.pid
                        patientName = user.name
                        patientEmail = user.email
                        patientPhone = user.phone
                        patientAge = "\(user.age)"
                        patientGender = user.gender
                        patientAddress = user.address
                        patientWork = user.work
                        patientLogin = true
                        
                        print("✅ Saved PID:", patientPID)
                        
                        navigate = true
                        
                    } else {
                        loginError = loginResponse.message
                        print("❌ Server error:", loginResponse.message)
                    }
                    
                } catch {
                    loginError = "JSON decode error: \(error.localizedDescription)"
                    print("❌ Decode error:", error)
                }
            }
        }.resume()
    }
}

#Preview {
    PatientLoginView()
}

struct LoginMdoel: Codable {
    let status, message: String
    let data: LoginMdoelData
}

struct LoginMdoelData: Codable {
    let pid, name: String
    let age: Int
    let gender, phone, email, address: String
    let work, createdAt: String

    enum CodingKeys: String, CodingKey {
        case pid, name, age, gender, phone, email, address, work
        case createdAt = "created_at"
    }
}
