import SwiftUI

// MARK: - Doctor Profile View (Liquid Glass UI)

struct DoctorProfileView: View {
    @EnvironmentObject var profile: DoctorProfile
    @AppStorage("doctorDID") private var doctorDID: String = ""
    @State private var isEditing = false
    @State private var showSaveAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showProfile = false
    @State private var showFields = false
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    
    // Validation states
    @State private var nameValidation: ValidateResult = .valid
    @State private var emailValidation: ValidateResult = .valid
    @State private var specializationValidation: ValidateResult = .valid
    @State private var hospitalValidation: ValidateResult = .valid
    @State private var phoneValidation: ValidateResult = .valid
    
    var body: some View {
        ZStack {
            LiquidAmbientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    // Doctor Profile Header
                    doctorHeaderSection
                    
                    // Edit Profile Trigger Button
                    if !isEditing {
                        Button(action: {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isEditing = true
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "pencil.line")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Edit Clinical Profile")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "0EA5E9"), Color(hex: "06B6D4")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color(hex: "06B6D4").opacity(0.35), radius: 10, y: 4)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.horizontal, 20)
                        .scaleEffect(showFields ? 1 : 0.9)
                        .opacity(showFields ? 1 : 0)
                    }

                    // Profile Fields Matrix
                    VStack(spacing: 14) {
                        // Full Name
                        ValidatedProfileField(
                            icon: "person.fill",
                            label: "Full Name",
                            value: $profile.name,
                            isEditing: isEditing,
                            index: 0,
                            showFields: $showFields,
                            validation: $nameValidation,
                            validator: validateName
                        )

                        // Email
                        ValidatedProfileField(
                            icon: "envelope.fill",
                            label: "Institutional Email",
                            value: $profile.email,
                            isEditing: isEditing,
                            index: 1,
                            showFields: $showFields,
                            validation: $emailValidation,
                            validator: validateEmail
                        )

                        // Gender Picker
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(LiquidGlassTheme.primaryTeal.opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "figure.dress.line.vertical.figure")
                                        .font(.system(size: 14))
                                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                                }
                                Text("Gender")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }

                            if isEditing {
                                Picker("Gender", selection: $profile.gender) {
                                    Text("Male").tag("Male")
                                    Text("Female").tag("Female")
                                    Text("Other").tag("Other")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            } else {
                                HStack {
                                    Text(profile.gender.isEmpty ? "Unspecified" : profile.gender)
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(.secondarySystemBackground).opacity(0.7))
                                .cornerRadius(10)
                            }
                        }
                        .padding(16)
                        .liquidGlass(cornerRadius: 18)
                        .scaleEffect(showFields ? 1 : 0.9)
                        .opacity(showFields ? 1 : 0)

                        // Specialization Field
                        ValidatedProfileField(
                            icon: "cross.case.fill",
                            label: "Medical Specialization",
                            value: $profile.specialization,
                            isEditing: isEditing,
                            index: 3,
                            showFields: $showFields,
                            validation: $specializationValidation,
                            validator: validateSpecialization
                        )

                        // Hospital Field
                        ValidatedProfileField(
                            icon: "building.2.fill",
                            label: "Hospital / Clinical Center",
                            value: $profile.hospital,
                            isEditing: isEditing,
                            index: 4,
                            showFields: $showFields,
                            validation: $hospitalValidation,
                            validator: validateHospital
                        )

                        // Phone Field
                        ValidatedProfileField(
                            icon: "phone.fill",
                            label: "Direct Mobile",
                            value: $profile.phone,
                            isEditing: isEditing,
                            index: 5,
                            showFields: $showFields,
                            validation: $phoneValidation,
                            validator: validatePhone
                        )
                    }
                    .padding(.horizontal, 20)

                    // Save / Cancel Action Bar
                    if isEditing {
                        HStack(spacing: 12) {
                            Button(action: {
                                let impactLight = UIImpactFeedbackGenerator(style: .light)
                                impactLight.impactOccurred()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isEditing = false
                                    profile.saveOriginalData()
                                    resetValidation()
                                }
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 15, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .foregroundColor(.white.opacity(0.85))
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(ScaleButtonStyle())

                            Button(action: {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                validateAllFields()
                                if isProfileValid {
                                    saveProfile()
                                } else {
                                    alertTitle = "Validation Error"
                                    alertMessage = "Please fix all validation errors before saving"
                                    showSaveAlert = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if isLoading {
                                        ProgressView().tint(.white)
                                        Text("Saving...")
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 16))
                                        Text("Save Changes")
                                    }
                                }
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(
                                        colors: (isLoading || !profile.hasChanges() || !isProfileValid)
                                            ? [Color.white.opacity(0.15), Color.white.opacity(0.1)]
                                            : [Color(hex: "10B981"), Color(hex: "059669")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                                .shadow(color: (isLoading || !profile.hasChanges() || !isProfileValid) ? .clear : Color(hex: "10B981").opacity(0.4), radius: 10, y: 4)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .disabled(isLoading || !profile.hasChanges() || !isProfileValid)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    }

                    // Account Deletion Danger Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "EF4444"))
                            Text("Account Security Zone")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }

                        Text("Permanently delete your physician account and remove all associated diagnostic signatures. This cannot be undone.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)

                        Button(action: { showDeleteConfirmation = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 14))
                                Text(isDeleting ? "Deleting..." : "Permanently Delete Account")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "EF4444").opacity(0.8), Color(hex: "DC2626").opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding(18)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red.opacity(0.25), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    Spacer(minLength: 40)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .alert(alertTitle, isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .confirmationDialog(
            "Delete Physician Account",
            isPresented: $showDeleteConfirmation,
            presenting: (),
            actions: { _ in
                Button("Delete Account", role: .destructive) {
                    deleteAccount()
                }
                Button("Cancel", role: .cancel) { }
            },
            message: { _ in
                Text("Are you sure you want to permanently delete your account? All your profile data and associated records will be erased. This cannot be undone.")
            }
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showProfile = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                showFields = true
            }
        }
        .onChange(of: profile.name) { newValue in
            if isEditing { nameValidation = validateName(newValue) }
        }
        .onChange(of: profile.email) { newValue in
            if isEditing { emailValidation = validateEmail(newValue) }
        }
        .onChange(of: profile.specialization) { newValue in
            if isEditing { specializationValidation = validateSpecialization(newValue) }
        }
        .onChange(of: profile.hospital) { newValue in
            if isEditing { hospitalValidation = validateHospital(newValue) }
        }
        .onChange(of: profile.phone) { newValue in
            if isEditing { phoneValidation = validatePhone(newValue) }
        }
    }

    // MARK: - Header Component
    private var doctorHeaderSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [LiquidGlassTheme.vibrantCyan.opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 65
                        )
                    )
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 86, height: 86)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.25), radius: 8, x: 0, y: 4)

                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 76, height: 76)
                    .foregroundStyle(LiquidGlassTheme.gradientPrimary)
            }
            .scaleEffect(showProfile ? 1 : 0.8)

            VStack(spacing: 6) {
                Text(profile.name.isEmpty ? "Doctor" : profile.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    Image(systemName: "stethoscope")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                    Text(profile.specialization.isEmpty ? "Nephrology Specialist" : profile.specialization)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                }
                
                if !doctorDID.isEmpty {
                    Text("DID: \(doctorDID)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(LiquidGlassTheme.vibrantCyan)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(LiquidGlassTheme.primaryTeal.opacity(0.12)))
                        .overlay(Capsule().strokeBorder(LiquidGlassTheme.primaryTeal.opacity(0.3), lineWidth: 1))
                }
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: - Validation Functions
    private func validateName(_ name: String) -> ValidateResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Name is required") }
        let nameRegex = "^[a-zA-Z\\s.]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        guard predicate.evaluate(with: trimmed) else { return .invalid("Only alphabets allowed") }
        guard trimmed.count >= 2 else { return .invalid("At least 2 characters required") }
        return .valid
    }
    
    private func validateEmail(_ email: String) -> ValidateResult {
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
    
    private func validateSpecialization(_ specialization: String) -> ValidateResult {
        let trimmed = specialization.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Specialization is required") }
        guard trimmed.count >= 3 else { return .invalid("At least 3 characters required") }
        return .valid
    }
    
    private func validateHospital(_ hospital: String) -> ValidateResult {
        let trimmed = hospital.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Hospital name is required") }
        guard trimmed.count >= 3 else { return .invalid("At least 3 characters required") }
        return .valid
    }
    
    private func validatePhone(_ phone: String) -> ValidateResult {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Phone number is required") }
        let cleanPhone = trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard cleanPhone.count == 10 else { return .invalid("Must be 10 digits") }
        guard let first = cleanPhone.first, "6789".contains(first) else {
            return .invalid("Must start with 6, 7, 8, or 9")
        }
        return .valid
    }
    
    private var isProfileValid: Bool {
        nameValidation == .valid &&
        emailValidation == .valid &&
        specializationValidation == .valid &&
        hospitalValidation == .valid &&
        phoneValidation == .valid
    }
    
    private func validateAllFields() {
        nameValidation = validateName(profile.name)
        emailValidation = validateEmail(profile.email)
        specializationValidation = validateSpecialization(profile.specialization)
        hospitalValidation = validateHospital(profile.hospital)
        phoneValidation = validatePhone(profile.phone)
    }
    
    private func resetValidation() {
        nameValidation = .valid
        emailValidation = .valid
        specializationValidation = .valid
        hospitalValidation = .valid
        phoneValidation = .valid
    }

    // MARK: - Delete Account Function (Preserved Backend)
    private func deleteAccount() {
        withAnimation {
            isDeleting = true
        }

        guard !doctorDID.isEmpty else {
            alertMessage = "Doctor ID not found"
            showSaveAlert = true
            isDeleting = false
            return
        }

        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/dprofile.php") else {
            alertMessage = "Invalid URL"
            showSaveAlert = true
            isDeleting = false
            return
        }

        let body: [String: Any] = ["did": doctorDID]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            alertMessage = "Failed to create request"
            showSaveAlert = true
            isDeleting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                withAnimation {
                    isDeleting = false
                }

                if let error = error {
                    alertMessage = "Network Error: \(error.localizedDescription)"
                    showSaveAlert = true
                    return
                }

                guard let data = data, !data.isEmpty else {
                    alertMessage = "No response from server. Please try again."
                    showSaveAlert = true
                    return
                }

                struct APIResponse: Codable {
                    let success: Bool
                    let message: String
                }

                do {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    alertMessage = response.message

                    if response.success {
                        let impactSuccess = UINotificationFeedbackGenerator()
                        impactSuccess.notificationOccurred(.success)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            UserDefaults.standard.removeObject(forKey: "doctorDID")
                        }
                    }
                } catch let decodingError {
                    alertMessage = "Failed to process response: \(decodingError.localizedDescription)"
                }

                showSaveAlert = true
            }
        }.resume()
    }

    // MARK: - Save Profile Function (Preserved Backend)
    func saveProfile() {
        withAnimation {
            isLoading = true
        }

        guard !doctorDID.isEmpty else {
            alertMessage = "Doctor ID not found"
            showSaveAlert = true
            isLoading = false
            return
        }

        let body: [String: Any] = [
            "did": doctorDID,
            "name": profile.name.trimmingCharacters(in: .whitespaces),
            "email": profile.email.trimmingCharacters(in: .whitespaces),
            "gender": profile.gender,
            "specialization": profile.specialization.trimmingCharacters(in: .whitespaces),
            "hospital": profile.hospital.trimmingCharacters(in: .whitespaces),
            "phone": profile.phone.trimmingCharacters(in: .whitespaces)
        ]

        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/dprofile.php") else {
            alertMessage = "Invalid URL"
            showSaveAlert = true
            isLoading = false
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            alertMessage = "Failed to create request"
            showSaveAlert = true
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                withAnimation {
                    isLoading = false
                }

                if let error = error {
                    alertMessage = "Network Error: \(error.localizedDescription)"
                    showSaveAlert = true
                    return
                }

                guard let data = data, !data.isEmpty else {
                    alertMessage = "No response from server. Please try again."
                    showSaveAlert = true
                    return
                }

                struct APIResponse: Codable {
                    let success: Bool
                    let message: String
                }

                do {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    alertMessage = response.message

                    if response.success {
                        let impactSuccess = UINotificationFeedbackGenerator()
                        impactSuccess.notificationOccurred(.success)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isEditing = false
                        }
                        profile.saveOriginalData()
                        resetValidation()
                    }
                } catch let decodingError {
                    alertMessage = "Failed to process response: \(decodingError.localizedDescription)"
                }

                showSaveAlert = true
            }
        }.resume()
    }
}

// MARK: - Validated Profile Field Component (Liquid Glass)
struct ValidatedProfileField: View {
    var icon: String
    var label: String
    @Binding var value: String
    var isEditing: Bool
    var index: Int
    @Binding var showFields: Bool
    @Binding var validation: ValidateResult
    let validator: (String) -> ValidateResult

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LiquidGlassTheme.primaryTeal.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                }
                Text(label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }

            if isEditing {
                VStack(alignment: .leading, spacing: 6) {
                    TextField(label, text: $value)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(Color(.secondarySystemBackground).opacity(0.7))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isError ? Color.red : LiquidGlassTheme.primaryTeal.opacity(0.4), lineWidth: 1)
                        )
                    
                    if case .invalid(let message) = validation {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 10))
                            Text(message)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "F87171"))
                        .padding(.horizontal, 4)
                    }
                }
            } else {
                HStack {
                    Text(value.isEmpty ? "Not provided" : value)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(12)
                .background(Color(.secondarySystemBackground).opacity(0.7))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 18)
        .scaleEffect(showFields ? 1 : 0.9)
        .opacity(showFields ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.04), value: showFields)
        .onChange(of: value) { newValue in
            validation = validator(newValue)
        }
    }
    
    private var isError: Bool {
        if case .invalid = validation {
            return true
        }
        return false
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    DoctorProfileView()
        .environmentObject(DoctorProfile())
}
