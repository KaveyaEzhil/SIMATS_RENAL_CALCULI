import SwiftUI

// MARK: - DoctorValidationResult Enum
enum DoctorValidationResult: Equatable {
    case valid
    case invalid(String)
    
    var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .invalid(let message):
            return message
        }
    }
}

// MARK: - DoctorValidatedTextField Component (Liquid Glass)
struct DoctorValidatedTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    @Binding var validation: DoctorValidationResult
    let validator: (String) -> DoctorValidationResult
    @FocusState.Binding var focusedField: DoctorSignupView.Field?
    var fieldType: DoctorSignupView.Field
    
    private var isFocused: Bool {
        focusedField == fieldType
    }
    
    private var borderColor: Color {
        if case .invalid = validation {
            return Color(hex: "EF4444")
        }
        return isFocused ? LiquidGlassTheme.vibrantCyan.opacity(0.85) : Color.white.opacity(0.4)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                // Tinted icon circle medallion
                ZStack {
                    Circle()
                        .fill(LiquidGlassTheme.primaryTeal.opacity(isFocused ? 0.20 : 0.12))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isFocused ? LiquidGlassTheme.vibrantCyan : LiquidGlassTheme.primaryTeal)
                }
                
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(.secondary)
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .focused($focusedField, equals: fieldType)
                
                if !text.isEmpty && isFocused {
                    Button {
                        text = ""
                        validation = validator("")
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground).opacity(isFocused ? 0.90 : 0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: isFocused ? 1.5 : 1.0)
            )
            .shadow(
                color: isFocused ? LiquidGlassTheme.primaryTeal.opacity(0.2) : Color.black.opacity(0.02),
                radius: 6,
                x: 0,
                y: 2
            )
            .animation(.spring(response: 0.3), value: isFocused)
            
            if case .invalid(let message) = validation {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 10))
                    Text(message)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(Color(hex: "EF4444"))
                .padding(.horizontal, 6)
            }
        }
        .onChange(of: text) { newValue in
            validation = validator(newValue)
        }
    }
}

// MARK: - DoctorValidatedSecureField Component (Liquid Glass)
struct DoctorValidatedSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    @Binding var validation: DoctorValidationResult
    let validator: (String) -> DoctorValidationResult
    @FocusState.Binding var focusedField: DoctorSignupView.Field?
    var fieldType: DoctorSignupView.Field
    
    private var isFocused: Bool {
        focusedField == fieldType
    }
    
    private var borderColor: Color {
        if case .invalid = validation {
            return Color(hex: "EF4444")
        }
        return isFocused ? LiquidGlassTheme.vibrantCyan.opacity(0.85) : Color.white.opacity(0.4)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                // Tinted icon circle medallion
                ZStack {
                    Circle()
                        .fill(LiquidGlassTheme.primaryTeal.opacity(isFocused ? 0.20 : 0.12))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isFocused ? LiquidGlassTheme.vibrantCyan : LiquidGlassTheme.primaryTeal)
                }
                
                if showPassword {
                    TextField("", text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(.secondary)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .focused($focusedField, equals: fieldType)
                } else {
                    SecureField("", text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(.secondary)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .focused($focusedField, equals: fieldType)
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showPassword.toggle()
                    }
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: 28)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground).opacity(isFocused ? 0.90 : 0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: isFocused ? 1.5 : 1.0)
            )
            .shadow(
                color: isFocused ? LiquidGlassTheme.primaryTeal.opacity(0.2) : Color.black.opacity(0.02),
                radius: 6,
                x: 0,
                y: 2
            )
            .animation(.spring(response: 0.3), value: isFocused)
            
            if case .invalid(let message) = validation {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 10))
                    Text(message)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(Color(hex: "EF4444"))
                .padding(.horizontal, 6)
            }
        }
        .onChange(of: text) { newValue in
            validation = validator(newValue)
        }
    }
}

// MARK: - DoctorPasswordStrengthView (Liquid Glass Glowing Bars)
struct DoctorPasswordStrengthView: View {
    let password: String
    
    private var strength: (level: Int, text: String, color: Color) {
        if password.count < 6 {
            return (1, "Weak", Color(hex: "EF4444"))
        } else if password.count < 8 {
            return (2, "Fair", Color(hex: "F59E0B"))
        } else if password.count < 10 {
            return (3, "Good", Color(hex: "3B82F6"))
        } else {
            let hasLetter = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
            let hasNumber = password.range(of: "\\d", options: .regularExpression) != nil
            let hasSpecialChar = password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil
            
            if hasLetter && hasNumber && hasSpecialChar {
                return (4, "Strong", Color(hex: "10B981"))
            } else if hasLetter && hasNumber {
                return (3, "Good", Color(hex: "3B82F6"))
            } else {
                return (2, "Fair", Color(hex: "F59E0B"))
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                ForEach(1...4, id: \.self) { level in
                    Capsule()
                        .fill(level <= strength.level ? strength.color : Color.secondary.opacity(0.25))
                        .frame(height: 4)
                        .shadow(color: level <= strength.level ? strength.color.opacity(0.5) : .clear, radius: 4)
                }
            }
            
            HStack {
                Text("Password Security:")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(strength.text)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(strength.color)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - DoctorSignupView (Liquid Glass UI)
struct DoctorSignupView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var specialization = ""
    @State private var hospital = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var gender = ""
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var navigateToLogin = false
    @State private var navigateToDashboard = false
    @State private var isLoading = false
    
    // Animation states
    @State private var headerScale: CGFloat = 0.8
    @State private var headerOpacity: Double = 0
    @State private var formOffset: CGFloat = 30
    @State private var formOpacity: Double = 0
    
    // Validation states
    @State private var nameValidation: DoctorValidationResult = .valid
    @State private var emailValidation: DoctorValidationResult = .valid
    @State private var specializationValidation: DoctorValidationResult = .valid
    @State private var hospitalValidation: DoctorValidationResult = .valid
    @State private var phoneValidation: DoctorValidationResult = .valid
    @State private var genderValidation: DoctorValidationResult = .valid
    @State private var passwordValidation: DoctorValidationResult = .valid
    @State private var confirmPasswordValidation: DoctorValidationResult = .valid
    
    // Focus states for field animations
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, email, specialization, hospital, phone, gender, password, confirmPassword
    }
    
    // Store doctor session data
    @AppStorage("doctorDID") var doctorDID: String = ""
    @AppStorage("doctorName") var doctorName: String = ""
    @AppStorage("doctorEmail") var doctorEmail: String = ""
    @AppStorage("doctorPhone") var doctorPhone: String = ""
    @AppStorage("doctorSpecialization") var doctorSpecialization: String = ""
    @AppStorage("doctorHospital") var doctorHospital: String = ""
    @AppStorage("doctorGender") var doctorGender: String = ""
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        ZStack {
            // Fluid ambient backdrop
            LiquidAmbientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Section
                    headerSection
                        .scaleEffect(headerScale)
                        .opacity(headerOpacity)
                    
                    // Frosted Glass Form Container
                    formContainer
                        .offset(y: formOffset)
                        .opacity(formOpacity)
                    
                    // Footer Clinical Notice
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 13))
                            .foregroundColor(LiquidGlassTheme.primaryTeal)
                        Text("Encrypted Clinical Portal • HIPAA Compliant Access")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            
            // Hidden Navigation Links
            NavigationLink("", destination: DoctorAppRootView(), isActive: $navigateToDashboard)
                .hidden()
            
            NavigationLink("", destination: DoctorLoginView(), isActive: $navigateToLogin)
                .hidden()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .alert(alertTitle, isPresented: $showAlert) {
            alertButtons
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: name) { newValue in
            nameValidation = validateName(newValue)
        }
        .onChange(of: email) { newValue in
            emailValidation = validateEmail(newValue)
        }
        .onChange(of: specialization) { newValue in
            specializationValidation = validateSpecialization(newValue)
        }
        .onChange(of: hospital) { newValue in
            hospitalValidation = validateHospital(newValue)
        }
        .onChange(of: phone) { newValue in
            phoneValidation = validatePhone(newValue)
        }
        .onChange(of: gender) { newValue in
            genderValidation = validateGender(newValue)
        }
        .onChange(of: password) { newValue in
            passwordValidation = validatePassword(newValue)
            if !confirmPassword.isEmpty {
                confirmPasswordValidation = validateConfirmPassword(confirmPassword)
            }
        }
        .onChange(of: confirmPassword) { newValue in
            confirmPasswordValidation = validateConfirmPassword(newValue)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                LiquidGlassTheme.vibrantCyan.opacity(0.35),
                                LiquidGlassTheme.primaryTeal.opacity(0.12),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 15,
                            endRadius: 55
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 8)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 72, height: 72)
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
                    .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.25), radius: 14, x: 0, y: 6)
                
                Image(systemName: "stethoscope")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(LiquidGlassTheme.gradientPrimary)
                    .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.3), radius: 6, x: 0, y: 2)
            }
            .padding(.top, 4)
            
            VStack(spacing: 6) {
                LiquidGlassPill(
                    title: "CLINICAL REGISTRATION",
                    icon: "cross.case.fill",
                    color: LiquidGlassTheme.primaryTeal,
                    isGlowing: true
                )
                
                Text("Doctor Registration")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primary, Color.primary.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Join our verified nephrology clinical network")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Form Container
    private var formContainer: some View {
        VStack(spacing: 18) {
            formFields
            
            signupButton
            
            loginLink
        }
        .padding(20)
        .liquidGlass(cornerRadius: 24, shadowRadius: 18)
    }
    
    // MARK: - Form Fields
    private var formFields: some View {
        VStack(spacing: 16) {
            // Full Name
            DoctorValidatedTextField(
                icon: "person.fill",
                placeholder: "Full Name (e.g. Dr. Jane Smith)",
                text: $name,
                keyboardType: .default,
                validation: $nameValidation,
                validator: validateName,
                focusedField: $focusedField,
                fieldType: .name
            )
            .textContentType(.name)
            .autocapitalization(.words)
            .focused($focusedField, equals: .name)
            
            // Email Address
            DoctorValidatedTextField(
                icon: "envelope.fill",
                placeholder: "Medical / Institutional Email",
                text: $email,
                keyboardType: .emailAddress,
                validation: $emailValidation,
                validator: validateEmail,
                focusedField: $focusedField,
                fieldType: .email
            )
            .textContentType(.emailAddress)
            .autocapitalization(.none)
            .focused($focusedField, equals: .email)
            
            // Specialization
            DoctorValidatedTextField(
                icon: "cross.case.fill",
                placeholder: "Specialization (e.g. Nephrologist, Urologist)",
                text: $specialization,
                keyboardType: .default,
                validation: $specializationValidation,
                validator: validateSpecialization,
                focusedField: $focusedField,
                fieldType: .specialization
            )
            .autocapitalization(.words)
            .focused($focusedField, equals: .specialization)
            
            // Hospital
            DoctorValidatedTextField(
                icon: "building.2.fill",
                placeholder: "Hospital / Medical Center",
                text: $hospital,
                keyboardType: .default,
                validation: $hospitalValidation,
                validator: validateHospital,
                focusedField: $focusedField,
                fieldType: .hospital
            )
            .autocapitalization(.words)
            .focused($focusedField, equals: .hospital)
            
            // Phone
            DoctorValidatedTextField(
                icon: "phone.fill",
                placeholder: "Direct Mobile (10 digits)",
                text: $phone,
                keyboardType: .phonePad,
                validation: $phoneValidation,
                validator: validatePhone,
                focusedField: $focusedField,
                fieldType: .phone
            )
            .focused($focusedField, equals: .phone)
            
            // Gender Selector
            genderPicker
            
            // Password
            DoctorValidatedSecureField(
                icon: "lock.fill",
                placeholder: "Password (min. 6 characters)",
                text: $password,
                showPassword: $showPassword,
                validation: $passwordValidation,
                validator: validatePassword,
                focusedField: $focusedField,
                fieldType: .password
            )
            .focused($focusedField, equals: .password)
            
            // Password Strength Indicator
            if !password.isEmpty {
                DoctorPasswordStrengthView(password: password)
                    .padding(.horizontal, 4)
            }
            
            // Confirm Password
            DoctorValidatedSecureField(
                icon: "lock.shield.fill",
                placeholder: "Confirm Password",
                text: $confirmPassword,
                showPassword: $showConfirmPassword,
                validation: $confirmPasswordValidation,
                validator: validateConfirmPassword,
                focusedField: $focusedField,
                fieldType: .confirmPassword
            )
            .focused($focusedField, equals: .confirmPassword)
        }
    }
    
    // MARK: - Gender Picker (Liquid Glass)
    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Menu {
                ForEach(genders, id: \.self) { gen in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            gender = gen
                            genderValidation = validateGender(gen)
                        }
                    }) {
                        HStack {
                            Text(gen)
                            if gender == gen {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    // Tinted icon circle medallion
                    ZStack {
                        Circle()
                            .fill(LiquidGlassTheme.primaryTeal.opacity(focusedField == .gender ? 0.20 : 0.12))
                            .frame(width: 34, height: 34)
                        
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(focusedField == .gender ? LiquidGlassTheme.vibrantCyan : LiquidGlassTheme.primaryTeal)
                    }
                    
                    Text(gender.isEmpty ? "Select Gender" : gender)
                        .foregroundColor(gender.isEmpty ? .secondary : .primary)
                        .font(.system(size: 14, weight: .medium))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemBackground).opacity(focusedField == .gender ? 0.90 : 0.72))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(genderBorderColor, lineWidth: focusedField == .gender ? 1.5 : 1.0)
                )
                .shadow(
                    color: focusedField == .gender ? LiquidGlassTheme.primaryTeal.opacity(0.2) : Color.black.opacity(0.02),
                    radius: 6,
                    x: 0,
                    y: 2
                )
            }
            .focused($focusedField, equals: .gender)
            
            if case .invalid(let message) = genderValidation {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 10))
                    Text(message)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(Color(hex: "EF4444"))
                .padding(.horizontal, 6)
            }
        }
    }
    
    // MARK: - Signup Button (Liquid Glass Glow)
    private var signupButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            focusedField = nil
            validateAllFields()
            if isFormValid {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    signupDoctor()
                }
            }
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(isLoading ? "Registering Physician..." : "Create Professional Account")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
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
                    if isFormValid && !isLoading {
                        LiquidGlassTheme.gradientPrimary
                    } else {
                        LinearGradient(
                            colors: [
                                LiquidGlassTheme.primaryTeal.opacity(0.40),
                                LiquidGlassTheme.vibrantCyan.opacity(0.28)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(
                color: (isFormValid && !isLoading)
                    ? LiquidGlassTheme.primaryTeal.opacity(0.4)
                    : Color.clear,
                radius: 14,
                x: 0,
                y: 6
            )
        }
        .disabled(!isFormValid || isLoading)
        .padding(.top, 4)
    }
    
    // MARK: - Login Link
    private var loginLink: some View {
        NavigationLink(destination: DoctorLoginView()) {
            HStack(spacing: 6) {
                Text("Already registered?")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                Text("Sign In Here")
                    .foregroundColor(LiquidGlassTheme.primaryTeal)
                    .fontWeight(.bold)
                    .font(.system(size: 13, design: .rounded))
            }
            .padding(.vertical, 6)
        }
    }
    
    // MARK: - Alert Buttons
    private var alertButtons: some View {
        Button("OK", role: .cancel) {
            if alertTitle == "Success" {
                withAnimation(.easeInOut(duration: 0.3)) {
                    navigateToDashboard = true
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    private var genderBorderColor: Color {
        switch genderValidation {
        case .valid:
            return focusedField == .gender ? LiquidGlassTheme.vibrantCyan.opacity(0.85) : Color.white.opacity(0.4)
        case .invalid:
            return Color(hex: "EF4444")
        }
    }
    
    private var isFormValid: Bool {
        nameValidation == .valid &&
        emailValidation == .valid &&
        specializationValidation == .valid &&
        hospitalValidation == .valid &&
        phoneValidation == .valid &&
        genderValidation == .valid &&
        passwordValidation == .valid &&
        confirmPasswordValidation == .valid
    }
    
    // MARK: - Validation Functions
    private func validateName(_ name: String) -> DoctorValidationResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Name is required") }
        let nameRegex = "^[a-zA-Z\\s.]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        guard predicate.evaluate(with: trimmed) else { return .invalid("Only alphabets allowed") }
        guard trimmed.count >= 2 else { return .invalid("At least 2 characters required") }
        return .valid
    }

    private func validateEmail(_ email: String) -> DoctorValidationResult {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Email is required") }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard predicate.evaluate(with: trimmed) else { return .invalid("Invalid email format") }
        let allowedDomains = ["gmail.com", "yahoo.com", "outlook.com", "hotmail.com", "icloud.com"]
        let components = trimmed.components(separatedBy: "@")
        guard components.count == 2, let domain = components.last, allowedDomains.contains(domain.lowercased()) else {
            return .invalid("Please use a common email provider")
        }
        return .valid
    }
    
    private func validateSpecialization(_ specialization: String) -> DoctorValidationResult {
        let trimmed = specialization.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Specialization is required") }
        guard trimmed.count >= 3 else { return .invalid("At least 3 characters required") }
        return .valid
    }
    
    private func validateHospital(_ hospital: String) -> DoctorValidationResult {
        let trimmed = hospital.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Hospital name is required") }
        guard trimmed.count >= 3 else { return .invalid("At least 3 characters required") }
        return .valid
    }
    
    private func validatePhone(_ phone: String) -> DoctorValidationResult {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Phone number is required") }
        let cleanPhone = trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard cleanPhone.count == 10 else { return .invalid("Must be 10 digits") }
        guard let first = cleanPhone.first, "6789".contains(first) else {
            return .invalid("Must start with 6, 7, 8, or 9")
        }
        return .valid
    }
    
    private func validateGender(_ gender: String) -> DoctorValidationResult {
        return gender.isEmpty ? .invalid("Gender is required") : .valid
    }
    
    private func validatePassword(_ password: String) -> DoctorValidationResult {
        guard !password.isEmpty else { return .invalid("Password is required") }
        guard password.count >= 6 else { return .invalid("Minimum 6 characters required") }
        guard password.count <= 20 else { return .invalid("Maximum 20 characters allowed") }
        
        let hasLetter = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "\\d", options: .regularExpression) != nil
        
        if !hasLetter {
            return .invalid("Password must contain at least one letter")
        }
        if !hasNumber {
            return .invalid("Password must contain at least one number")
        }
        
        return .valid
    }
    
    private func validateConfirmPassword(_ confirmPassword: String) -> DoctorValidationResult {
        guard !confirmPassword.isEmpty else { return .invalid("Please confirm your password") }
        return confirmPassword == password ? .valid : .invalid("Passwords don't match")
    }
    
    // MARK: - Form Validation
    private func validateAllFields() {
        nameValidation = validateName(name)
        emailValidation = validateEmail(email)
        specializationValidation = validateSpecialization(specialization)
        hospitalValidation = validateHospital(hospital)
        phoneValidation = validatePhone(phone)
        genderValidation = validateGender(gender)
        passwordValidation = validatePassword(password)
        confirmPasswordValidation = validateConfirmPassword(confirmPassword)
    }
    
    // MARK: - Animation Functions
    private func startAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            headerScale = 1.0
            headerOpacity = 1.0
        }
        
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.15)) {
            formOffset = 0
            formOpacity = 1.0
        }
    }
    
    // MARK: - Signup Function with Validation
    func signupDoctor() {
        validateAllFields()
        
        if !isFormValid {
            alertTitle = "Validation Error"
            alertMessage = "Please fix all validation errors before submitting"
            showAlert = true
            return
        }
        
        callSignupAPI()
    }
    
    // MARK: - API Call
    func callSignupAPI() {
        isLoading = true
        
        let params: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "email": email.lowercased().trimmingCharacters(in: .whitespaces),
            "specialization": specialization.trimmingCharacters(in: .whitespaces),
            "hospital": hospital.trimmingCharacters(in: .whitespaces),
            "phone": phone,
            "gender": gender,
            "password": password
        ]
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/dsignup.php") else {
            alertTitle = "Error"
            alertMessage = "Invalid server URL"
            showAlert = true
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        request.timeoutInterval = 15
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    alertTitle = "Network Error"
                    alertMessage = "Please check your internet connection"
                    showAlert = true
                }
                print("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        alertTitle = "Server Error"
                        alertMessage = "Server returned status code: \(httpResponse.statusCode)"
                        showAlert = true
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    alertTitle = "Server Error"
                    alertMessage = "No data received from server"
                    showAlert = true
                }
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Server response: \(responseString)")
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    DispatchQueue.main.async {
                        alertTitle = "Server Error"
                        alertMessage = "Invalid JSON response from server"
                        showAlert = true
                    }
                    return
                }
                
                print("✅ Parsed JSON: \(json)")
                
                DispatchQueue.main.async {
                    if let status = json["status"] as? String, status == "success" {
                        let did = json["did"] as? String ?? ""
                        
                        doctorDID = did
                        doctorName = name.trimmingCharacters(in: .whitespaces)
                        doctorEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
                        doctorPhone = phone
                        doctorSpecialization = specialization.trimmingCharacters(in: .whitespaces)
                        doctorHospital = hospital.trimmingCharacters(in: .whitespaces)
                        doctorGender = gender
                        
                        print("✅ Doctor data saved - DID: \(did), Name: \(doctorName)")
                        
                        alertTitle = "Success"
                        alertMessage = "Account created successfully! Your Doctor ID: \(did)"
                        showAlert = true
                    } else {
                        alertTitle = "Signup Failed"
                        alertMessage = json["message"] as? String ?? "Unable to create account. Please try again."
                        showAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertTitle = "Server Error"
                    alertMessage = "Failed to parse server response"
                    showAlert = true
                }
                print("❌ JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// MARK: - PREVIEW
struct DoctorSignupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DoctorSignupView()
        }
    }
}
