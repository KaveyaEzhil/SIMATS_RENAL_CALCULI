import SwiftUI

struct DoctorForgotPasswordView: View {
    @State private var email = ""
    @State private var phone = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var verificationMessage = ""
    @State private var verificationColor = Color.clear
    
    @State private var step = 1 // 1: Verification, 2: Reset Password
    @State private var isLoading = false
    @State private var doctorName = ""
    
    var body: some View {
        ZStack {
            LiquidAmbientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "06B6D4").opacity(0.18))
                                .frame(width: 72, height: 72)
                            
                            Image(systemName: step == 1 ? "shield.lefthalf.filled" : "lock.rotation")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "38BDF8"), Color(hex: "06B6D4")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text("Credential Recovery")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(step == 1 ? "Physician Account Verification" : "Update Access Security")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Stepper Indicator Pill
                    HStack(spacing: 12) {
                        stepIndicator(num: 1, label: "Verification", isActive: step >= 1, isCurrent: step == 1)
                        Rectangle()
                            .fill(step == 2 ? LiquidGlassTheme.primaryTeal : Color.secondary.opacity(0.2))
                            .frame(width: 28, height: 2)
                        stepIndicator(num: 2, label: "Reset Password", isActive: step == 2, isCurrent: step == 2)
                    }
                    .padding(.vertical, 4)
                    
                    // Main Glass Card
                    VStack(spacing: 20) {
                        if step == 1 {
                            verificationStepView()
                        } else {
                            resetPasswordStepView()
                        }
                        
                        // Status message badge
                        if !verificationMessage.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: verificationColor == .green ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .font(.system(size: 14))
                                Text(verificationMessage)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(verificationColor == .green ? LiquidGlassTheme.emeraldSuccess : LiquidGlassTheme.coralDanger)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(verificationColor == .green ? LiquidGlassTheme.emeraldSuccess.opacity(0.15) : LiquidGlassTheme.coralDanger.opacity(0.15))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(verificationColor == .green ? LiquidGlassTheme.emeraldSuccess.opacity(0.3) : LiquidGlassTheme.coralDanger.opacity(0.3), lineWidth: 1)
                            )
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(22)
                    .liquidGlass(cornerRadius: 24)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Step Indicator
    private func stepIndicator(num: Int, label: String, isActive: Bool, isCurrent: Bool) -> some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isActive ? LiquidGlassTheme.primaryTeal : Color(.secondarySystemBackground))
                    .frame(width: 22, height: 22)
                Text("\(num)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isActive ? .white : .secondary)
            }
            Text(label)
                .font(.system(size: 12, weight: isCurrent ? .bold : .medium, design: .rounded))
                .foregroundColor(isActive ? .primary : .secondary)
        }
    }
    
    // 🔹 MARK: Step 1 - Verification View
    @ViewBuilder
    private func verificationStepView() -> some View {
        VStack(spacing: 16) {
            Text("Enter your registered medical institutional email or phone number to verify credentials.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
            
            // Email Input
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .foregroundColor(LiquidGlassTheme.primaryTeal)
                    .frame(width: 20)
                TextField("Registered Email", text: $email)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disabled(isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemBackground).opacity(0.7)))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.3), lineWidth: 1))
            
            HStack(spacing: 12) {
                Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 1)
                Text("OR")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 1)
            }
            .padding(.vertical, 2)
            
            // Phone Input
            HStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .foregroundColor(LiquidGlassTheme.primaryTeal)
                    .frame(width: 20)
                TextField("Direct Mobile (10 digits)", text: $phone)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .keyboardType(.numberPad)
                    .disabled(isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemBackground).opacity(0.7)))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.3), lineWidth: 1))
            
            Button(action: {
                verifyDoctor()
            }) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 16))
                        Text("Verify Physician Identity")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: (email.isEmpty && phone.isEmpty)
                            ? [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
                            : [Color(hex: "0EA5E9"), Color(hex: "06B6D4")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.25), lineWidth: 1))
                .shadow(color: (email.isEmpty && phone.isEmpty) ? .clear : LiquidGlassTheme.primaryTeal.opacity(0.4), radius: 10, y: 4)
            }
            .disabled(isLoading || (email.isEmpty && phone.isEmpty))
            .padding(.top, 6)
        }
    }
    
    // 🔹 MARK: Step 2 - Reset Password View
    @ViewBuilder
    private func resetPasswordStepView() -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "stethoscope")
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                    Text("Verified Physician: \(doctorName)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                Text("Specify a new clinical credential password (min. 6 characters)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundColor(LiquidGlassTheme.primaryTeal)
                    .frame(width: 20)
                SecureField("New Password (min 6 chars)", text: $newPassword)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .disabled(isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemBackground).opacity(0.7)))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.3), lineWidth: 1))
            
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(LiquidGlassTheme.primaryTeal)
                    .frame(width: 20)
                SecureField("Confirm New Password", text: $confirmPassword)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .disabled(isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemBackground).opacity(0.7)))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.3), lineWidth: 1))
            
            Button(action: {
                resetPassword()
            }) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 16))
                        Text("Confirm Password Update")
                            .font(.system(size: 15, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: (newPassword.isEmpty || confirmPassword.isEmpty)
                            ? [Color.white.opacity(0.15), Color.white.opacity(0.1)]
                            : [Color(hex: "10B981"), Color(hex: "059669")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.25), lineWidth: 1))
                .shadow(color: (newPassword.isEmpty || confirmPassword.isEmpty) ? .clear : Color(hex: "10B981").opacity(0.4), radius: 10, y: 4)
            }
            .disabled(isLoading || newPassword.isEmpty || confirmPassword.isEmpty)
            .padding(.top, 4)
            
            Button(action: {
                step = 1
                resetForm()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.left")
                    Text("Back to Verification")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "38BDF8"))
            }
            .padding(.top, 6)
        }
    }
    
    // ✅ MARK: Verify Doctor Account (Backend Preserved)
    private func verifyDoctor() {
        if email.isEmpty && phone.isEmpty {
            verificationMessage = "Enter email or phone"
            verificationColor = .red
            return
        }
        
        if !email.isEmpty && !email.contains("@") {
            verificationMessage = "Enter valid email format"
            verificationColor = .red
            return
        }
        
        if !phone.isEmpty && phone.count != 10 {
            verificationMessage = "Phone must be exactly 10 digits"
            verificationColor = .red
            return
        }
        
        isLoading = true
        let urlString = "http://14.139.187.229:8081/oct/renal/dforgot.php"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var payload: [String: String] = ["mode": "verify"]
        if !email.isEmpty {
            payload["email"] = email.lowercased()
        } else {
            payload["phone"] = phone
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { isLoading = false }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    verificationMessage = "Network error. Please try again."
                    verificationColor = .red
                }
                return
            }
            
            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = response["status"] as? String {
                
                DispatchQueue.main.async {
                    if status == "success" {
                        doctorName = (response["name"] as? String) ?? "Doctor"
                        verificationMessage = "Physician Identity Verified"
                        verificationColor = .green
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            step = 2
                        }
                    } else {
                        let msg = response["message"] as? String ?? "Verification failed"
                        verificationMessage = msg
                        verificationColor = .red
                    }
                }
            }
        }.resume()
    }
    
    // ✅ MARK: Reset Password (Backend Preserved)
    private func resetPassword() {
        if newPassword.count < 6 {
            verificationMessage = "Password must be at least 6 characters"
            verificationColor = .red
            return
        }
        
        if newPassword != confirmPassword {
            verificationMessage = "Passwords do not match"
            verificationColor = .red
            return
        }
        
        isLoading = true
        let urlString = "http://14.139.187.229:8081/oct/renal/dforgot.php"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var payload: [String: String] = [
            "mode": "reset",
            "password": newPassword
        ]
        
        if !email.isEmpty {
            payload["email"] = email.lowercased()
        } else {
            payload["phone"] = phone
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { isLoading = false }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    verificationMessage = "Network error"
                    verificationColor = .red
                }
                return
            }
            
            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = response["status"] as? String {
                
                DispatchQueue.main.async {
                    if status == "success" {
                        verificationMessage = "Password reset successfully!"
                        verificationColor = .green
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            resetForm()
                        }
                    } else {
                        let msg = response["message"] as? String ?? "Password reset failed"
                        verificationMessage = msg
                        verificationColor = .red
                    }
                }
            }
        }.resume()
    }
    
    // 🔹 MARK: Reset Form
    private func resetForm() {
        email = ""
        phone = ""
        newPassword = ""
        confirmPassword = ""
        doctorName = ""
        verificationMessage = ""
        step = 1
    }
}

struct DoctorForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorForgotPasswordView()
    }
}
