import SwiftUI

// MARK: - Case Review View (Enhanced UI/UX with Animations)

struct CaseReviewView: View {
    
    @State var caseItem: CaseItem
    
    @State private var showAnnotatedFullscreen = false
    @State private var diagnosisNotes: String = ""
    @State private var diagnosisConfirmed = false
    @State private var showSuccess = false
    @State private var isSubmitting = false
    @State private var submitError = ""
    @State private var diagnosisAlreadySaved = false
    
    // Animation states
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    @State private var imageScale: CGFloat = 0.9
    @State private var pulseAnimation = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // MARK: - Liquid Ambient Canvas
            LiquidAmbientBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Patient Clinical Overview Header (Liquid Glass)
                    patientInformationView
                    
                    // Annotated Diagnostic Scan Section (Liquid Glass Viewport)
                    if !caseItem.fullAnnotatedImageUrl.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Diagnostic CT Scan & Saliency Map", systemImage: "sparkle.magnifyingglass")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(colors: [LiquidGlassTheme.primaryTeal, LiquidGlassTheme.vibrantCyan], startPoint: .leading, endPoint: .trailing)
                                    )
                                Spacer()
                                
                                LiquidGlassPill(
                                    title: "AI Saliency",
                                    icon: "waveform.path.ecg",
                                    color: LiquidGlassTheme.primaryTeal
                                )
                            }
                            .padding(.horizontal, 4)
                            
                            ZStack(alignment: .topTrailing) {
                                annotatedImageView
                                    .scaleEffect(imageScale)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            showAnnotatedFullscreen = true
                                        }
                                    }
                                
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        showAnnotatedFullscreen = true
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                                            .font(.system(size: 12, weight: .bold))
                                        Text("Zoom")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(.ultraThinMaterial)
                                            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                                    )
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
                                    )
                                }
                                .padding(12)
                                .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                            }
                        }
                        .padding(14)
                        .liquidGlass(cornerRadius: 22, shadowRadius: 12)
                        .padding(.horizontal)
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    }
                    
                    // AI Results Telemetry Panel
                    aiResultsView
                    
                    // Doctor Clinical Assessment & Interaction Hub
                    doctorConfirmationView
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 12)
                .padding(.bottom, 160)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationBarTitle(caseItem.patientName, displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .toolbar(.hidden, for: .tabBar)
        .alert("Submission Error", isPresented: .constant(!submitError.isEmpty)) {
            Button("OK") {
                submitError = ""
            }
        } message: {
            Text(submitError)
        }
        .fullScreenCover(isPresented: $showAnnotatedFullscreen) {
            fullScreenImageContent
        }
        .sheet(isPresented: $showSuccess) {
            DiagnosisCompletedView {
                showSuccess = false
                diagnosisAlreadySaved = true
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear(perform: onAppearActions)
    }
    
    // MARK: - Extracted Views
    
    private var annotatedImageView: some View {
        Group {
            if let image = loadBase64Image(base64String: caseItem.fullAnnotatedImageUrl) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.2), radius: 10, x: 0, y: 5)
            } else if caseItem.fullAnnotatedImageUrl.hasPrefix("http"), let url = URL(string: caseItem.fullAnnotatedImageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.tertiarySystemFill))
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 320)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.2), radius: 10, x: 0, y: 5)
                    case .failure(_):
                        ErrorImageView()
                    @unknown default:
                        Color.gray.frame(height: 280).cornerRadius(16)
                    }
                }
            } else {
                ErrorImageView()
            }
        }
    }
    
    private var fullScreenImageContent: some View {
        Group {
            if let uiImage = loadBase64Image(base64String: caseItem.fullAnnotatedImageUrl) {
                FullScreenImageView(isPresented: $showAnnotatedFullscreen, uiImage: uiImage)
            } else if caseItem.fullAnnotatedImageUrl.hasPrefix("http") {
                FullScreenImageView(isPresented: $showAnnotatedFullscreen, imageUrl: caseItem.fullAnnotatedImageUrl)
            } else {
                FullScreenImageView(isPresented: $showAnnotatedFullscreen)
            }
        }
    }
    
    private var patientInformationView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                // Patient Avatar Medallion
                ZStack {
                    Circle()
                        .fill(LiquidGlassTheme.gradientPrimary)
                        .frame(width: 48, height: 48)
                        .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(caseItem.patientName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13))
                            .foregroundColor(LiquidGlassTheme.primaryTeal)
                    }
                    
                    HStack(spacing: 6) {
                        if !caseItem.pid.isEmpty {
                            Text("PID: \(caseItem.pid)")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.secondary)
                            Text("•")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(caseItem.age) yrs, \(caseItem.gender)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                LiquidGlassPill(
                    title: caseItem.diagnosisConfirmed == 1 ? "VERIFIED" : "IN-REVIEW",
                    icon: caseItem.diagnosisConfirmed == 1 ? "checkmark.seal.fill" : "hourglass",
                    color: caseItem.diagnosisConfirmed == 1 ? LiquidGlassTheme.emeraldSuccess : LiquidGlassTheme.amberWarning,
                    isGlowing: true
                )
            }
            
            // Patient Quick Cards
            HStack(spacing: 10) {
                PatientInfoCard(title: "Age", value: "\(caseItem.age) Yrs", icon: "calendar")
                PatientInfoCard(title: "Gender", value: caseItem.gender, icon: "figure.dress.line.vertical.figure")
                PatientInfoCard(title: "Scan ID", value: "#\(caseItem.id)", icon: "tag.fill")
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 22, shadowRadius: 14)
        .padding(.horizontal)
        .opacity(contentOpacity)
        .offset(y: contentOffset)
    }
    
    private var aiResultsView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                    
                    Text("AI Calculus Telemetry")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                LiquidGlassPill(
                    title: "\(caseItem.aiScore)% Confidence",
                    icon: "sparkles",
                    color: LiquidGlassTheme.primaryTeal,
                    isGlowing: true
                )
            }
            
            // Detection row
            HStack(spacing: 10) {
                AIResultCard(
                    title: "Detection Status",
                    value: caseItem.aiDetected ? "Calculus Found" : "No Calculus",
                    icon: caseItem.aiDetected ? "exclamationmark.triangle.fill" : "checkmark.shield.fill",
                    color: caseItem.aiDetected ? LiquidGlassTheme.coralDanger : LiquidGlassTheme.emeraldSuccess
                )
                
                AIResultCard(
                    title: "Stone Count",
                    value: "\(caseItem.aiCount) Stones",
                    icon: "number.circle.fill",
                    color: LiquidGlassTheme.purpleAccent
                )
                
                AIResultCard(
                    title: "Maximum Size",
                    value: caseItem.aiDetected ? "\(String(format: "%.1f", caseItem.aiSizeMM)) mm" : "—",
                    icon: "ruler",
                    color: LiquidGlassTheme.primaryTeal
                )
            }
            
            // Stone Sizes Detailed Spectrum
            if caseItem.aiDetected && !caseItem.stoneSizes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "circle.grid.2x2.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(LiquidGlassTheme.primaryTeal)
                        
                        Text("Stone Dimension Spectrum:")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(caseItem.stoneCount) detected")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(caseItem.stoneSizes.enumerated()), id: \.offset) { index, size in
                                HStack(spacing: 6) {
                                    Text("#\(index + 1)")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                                    
                                    Text(formatStoneSize(size))
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.6))
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(LiquidGlassTheme.primaryTeal.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LiquidGlassTheme.primaryTeal.opacity(0.06))
                )
            }
            
            // Anatomical Locations
            if caseItem.aiDetected && !caseItem.stoneLocations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 11))
                            .foregroundColor(LiquidGlassTheme.primaryTeal)
                        
                        Text("Anatomical Localization:")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    let columns = [GridItem(.flexible()), GridItem(.flexible())]
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Array(caseItem.stoneLocations.enumerated()), id: \.offset) { index, location in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(getLocationColor(for: location))
                                    .frame(width: 8, height: 8)
                                
                                Text("\(index + 1). \(location)")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.white.opacity(0.5))
                            )
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.4))
                )
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 22, shadowRadius: 14)
        .padding(.horizontal)
        .opacity(contentOpacity)
        .offset(y: contentOffset)
    }

    // Helper function to format stone size
    private func formatStoneSize(_ sizeString: String) -> String {
        let cleaned = sizeString
            .replacingOccurrences(of: "mm", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let number = Double(cleaned) {
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(number)) mm"
            } else {
                return String(format: "%.1f mm", number)
            }
        }
        return sizeString
    }

    private func getLocationColor(for location: String) -> Color {
        let lowercased = location.lowercased()
        if lowercased.contains("right") {
            return LiquidGlassTheme.emeraldSuccess
        } else if lowercased.contains("left") {
            return LiquidGlassTheme.softAzure
        } else if lowercased.contains("kidney") {
            return LiquidGlassTheme.purpleAccent
        } else if lowercased.contains("ureter") {
            return LiquidGlassTheme.amberWarning
        } else if lowercased.contains("bladder") {
            return LiquidGlassTheme.coralDanger
        }
        return LiquidGlassTheme.primaryTeal
    }
    
    // Quick clinical observation prompt chip
    @ViewBuilder
    private func clinicalSuggestionChip(_ text: String) -> some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            if diagnosisNotes.isEmpty {
                diagnosisNotes = text
            } else if !diagnosisNotes.contains(text) {
                diagnosisNotes += ". " + text
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 10))
                Text(text)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
            }
            .foregroundColor(LiquidGlassTheme.primaryTeal)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.65))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(LiquidGlassTheme.primaryTeal.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var doctorConfirmationView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(LiquidGlassTheme.primaryTeal.opacity(0.18))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: "stethoscope")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                }
                
                Text("Doctor Clinical Assessment & Interaction")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            
            // Quick Recommendation Chips for Attending Physician
            if !diagnosisAlreadySaved {
                VStack(alignment: .leading, spacing: 6) {
                    Text("CLINICAL RECOMMENDATION TEMPLATES")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            clinicalSuggestionChip("Calculus verified in renal parenchyma")
                            clinicalSuggestionChip("Conservative hydration & medical expulsive therapy")
                            clinicalSuggestionChip("Follow-up non-contrast CT in 4 weeks")
                            clinicalSuggestionChip("Urology surgical intervention indicated")
                        }
                    }
                }
                .padding(.bottom, 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("PHYSICIAN CLINICAL REVIEW & ADVICE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(diagnosisNotes.count) chars")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                ZStack(alignment: .topLeading) {
                    if diagnosisNotes.isEmpty {
                        Text("Enter your clinical evaluation, medical recommendations, and prescription advice for the patient...")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary.opacity(0.6))
                            .padding(.horizontal, 14)
                            .padding(.top, 14)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $diagnosisNotes)
                        .font(.system(size: 14))
                        .frame(minHeight: 120)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.systemBackground).opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    diagnosisNotes.isEmpty ?
                                    Color.white.opacity(0.8) :
                                    LiquidGlassTheme.primaryTeal.opacity(0.6),
                                    lineWidth: 1.2
                                )
                        )
                        .disabled(diagnosisAlreadySaved)
                }
            }
            
            // Already Submitted Message (Verified Doctor Seal)
            if diagnosisAlreadySaved {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LiquidGlassTheme.emeraldSuccess.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundColor(LiquidGlassTheme.emeraldSuccess)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Diagnosis Verified & Transmitted")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(LiquidGlassTheme.emeraldSuccess)
                        
                        Text("Official medical record has been finalized by attending physician.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LiquidGlassTheme.emeraldSuccess.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(LiquidGlassTheme.emeraldSuccess.opacity(0.25), lineWidth: 1)
                )
            } else {
                submitButtonView
                    .scaleEffect(isButtonDisabled ? 0.98 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isButtonDisabled)
                
                if isButtonDisabled && diagnosisNotes.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("Please write clinical advice (min 5 characters) before submitting.")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22, shadowRadius: 14)
        .padding(.horizontal)
        .opacity(contentOpacity)
        .offset(y: contentOffset)
    }
    
    private var submitButtonView: some View {
        Group {
            if isSubmitting {
                HStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    Text("Transmitting Doctor Diagnosis...")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LiquidGlassTheme.gradientPrimary.opacity(0.8))
                )
                .foregroundColor(.white)
            } else {
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        submitDiagnosis()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16))
                        Text("Confirm Diagnosis & Transmit to Patient")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        ZStack {
                            if isButtonDisabled {
                                Color.gray.opacity(0.5)
                            } else {
                                LiquidGlassTheme.gradientPrimary
                            }
                            
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(
                        color: isButtonDisabled ? .clear : LiquidGlassTheme.primaryTeal.opacity(0.35),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
                    .foregroundColor(.white)
                }
                .disabled(isButtonDisabled)
                .buttonStyle(LiquidGlassButtonStyle())
            }
        }
    }
    
    var isButtonDisabled: Bool {
        let trimmedNotes = diagnosisNotes.trimmingCharacters(in: .whitespaces)
        
        let disabled = trimmedNotes.isEmpty ||
               trimmedNotes.count < 5 ||
               isSubmitting ||
               diagnosisAlreadySaved
        
        return disabled
    }
    
    // MARK: - Helper function to load base64 image
    private func loadBase64Image(base64String: String) -> UIImage? {
        // Check if it's a base64 string (starts with data:image)
        if base64String.hasPrefix("data:image") || base64String.hasPrefix("/9j/") || base64String.count > 1000 {
            print("📸 Detected base64 image, length: \(base64String.count)")
            
            // Extract base64 data if it has a prefix
            let base64Data: String
            if base64String.contains(",") {
                base64Data = String(base64String.split(separator: ",").last ?? "")
            } else {
                base64Data = base64String
            }
            
            if let imageData = Data(base64Encoded: base64Data, options: .ignoreUnknownCharacters) {
                return UIImage(data: imageData)
            }
        }
        return nil
    }
    
    // MARK: - Submit Diagnosis - FIXED VERSION
    // MARK: - Submit Diagnosis - FIXED VERSION
    func submitDiagnosis() {
        let trimmedNotes = diagnosisNotes.trimmingCharacters(in: .whitespaces)
        
        print("\n📝 === DIAGNOSIS SUBMISSION PROCESS ===")
        print("📝 Current state before submit:")
        print("   - diagnosisAlreadySaved: \(diagnosisAlreadySaved)")
        print("   - notes length: \(trimmedNotes.count)")
        print("   - patientEmail: \(caseItem.patientEmail)")
        print("   - pid: \(caseItem.pid)")
        
        if trimmedNotes.isEmpty {
            submitError = "Diagnosis notes cannot be empty. Please write your diagnosis."
            print("❌ REJECTED: Notes are empty")
            return
        }
        
        if trimmedNotes.count < 5 {
            submitError = "Diagnosis notes must be at least 5 characters. Please provide more detail."
            print("❌ REJECTED: Notes too short (<5 chars)")
            return
        }
        
        // ✅ FIX: Check for pid instead of email
        if caseItem.pid.isEmpty {
            submitError = "Patient ID not available. Please go back and try again."
            print("❌ REJECTED: Patient ID (pid) missing")
            return
        }
        
        isSubmitting = true
        submitError = ""
        
        print("✅ VALIDATION PASSED - Preparing submission...")
        print("📝 Submitting diagnosis for patient: \(caseItem.patientName)")
        print("📝 Patient ID (pid): \(caseItem.pid)")
        print("📝 Diagnosis notes length: \(trimmedNotes.count) characters")
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/diagnosis.php") else {
            submitError = "Invalid server URL"
            isSubmitting = false
            print("❌ ERROR: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        // ✅ FIXED: Send pid instead of patient_email
        let body: [String: Any] = [
            "history_id": caseItem.id,   // ✅ THIS IS REQUIRED
            "diagnosis_notes": trimmedNotes,
            "diagnosis_confirmed": 1
        ]
        print("📝 History ID:", caseItem.id)
        print("📝 Patient ID (pid):", caseItem.pid)


        
        print("📤 Sending Body:", body)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            submitError = "Encoding error: \(error.localizedDescription)"
            isSubmitting = false
            print("❌ JSON Encoding Error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isSubmitting = false
                
                if let error = error {
                    self.submitError = "Network error: \(error.localizedDescription)"
                    print("❌ Network Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.submitError = "No response from server"
                    print("❌ No response data received")
                    return
                }
                
                let raw = String(data: data, encoding: .utf8) ?? "nil"
                print("📥 Raw Response: \(raw)")
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        
                        print("📥 Parsed JSON:", json)
                        
                        if let success = json["success"] as? Bool {
                            
                            if success {
                                print("✅ SUCCESS: Diagnosis saved to database")
                                print("✅ Setting diagnosisAlreadySaved = true")
                                
                                // ✅ FIX: Create a new CaseItem instance instead of modifying
                                let updatedCaseItem = CaseItem(
                                    id: self.caseItem.id,
                                    patientEmail: self.caseItem.patientEmail,
                                    patientName: self.caseItem.patientName,
                                    age: self.caseItem.age,
                                    gender: self.caseItem.gender,
                                    doctor: self.caseItem.doctor,
                                    stoneCount: self.caseItem.stoneCount,
                                    stoneSizes: self.caseItem.stoneSizes,
                                    stoneLocations: self.caseItem.stoneLocations,
                                    image: self.caseItem.image,
                                    pid: self.caseItem.pid,
                                    diagnosisNotes: trimmedNotes,
                                    diagnosisConfirmed: 1
                                )
                                
                                // Update the state with new instance
                                self.caseItem = updatedCaseItem
                                
                                // Update local state
                                self.diagnosisAlreadySaved = true
                                self.diagnosisNotes = trimmedNotes
                                self.showSuccess = true
                                
                            } else {
                                let errorMsg = json["message"] as? String ?? "Unknown error from server"
                                print("❌ Server Error: \(errorMsg)")
                                self.submitError = errorMsg
                            }
                            
                        } else {
                            self.submitError = "Invalid response: 'success' field missing"
                            print("❌ Missing 'success' field in response")
                        }
                        
                    } else {
                        self.submitError = "Invalid server response format"
                        print("❌ Could not parse JSON response")
                    }
                    
                } catch {
                    self.submitError = "JSON parse error: \(error.localizedDescription)"
                    print("❌ JSON Parse Error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    // MARK: - On Appear Actions
    private func onAppearActions() {
        print("🔍 DEBUG: CaseItem data on appear:")
        print("  - diagnosis_confirmed: \(caseItem.diagnosisConfirmed)")
        print("  - status: \(caseItem.status)")
        print("  - aiCount: \(caseItem.aiCount)")
        print("  - annotatedImage (first 100 chars): \(String(caseItem.fullAnnotatedImageUrl.prefix(100)))...")
        
        // Check if diagnosis is already confirmed (server-side check)
        if caseItem.diagnosisConfirmed == 1 {
            print("✅ Diagnosis CONFIRMED (1) - Mark as saved, disable editing")
            diagnosisAlreadySaved = true
            
            // Pre-fill diagnosis notes if available
            if !caseItem.diagnosisNotes.isEmpty {
                diagnosisNotes = caseItem.diagnosisNotes
            }
        } else {
            print("❌ Diagnosis NOT confirmed (0) - Allow editing, enable submit button")
            diagnosisAlreadySaved = false
        }
        
        // Animate content on appear
        withAnimation(.easeOut(duration: 0.6)) {
            contentOpacity = 1
            contentOffset = 0
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
            imageScale = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseAnimation.toggle()
        }
    }
}

// MARK: - Helper Views

struct ErrorImageView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundColor(.orange)
                .symbolEffect(.bounce, value: true)
            Text("Failed to load image")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.tertiarySystemFill))
        )
    }
}

// MARK: - Patient Info Card Component
struct PatientInfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.teal)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.subheadline)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

// MARK: - AI Result Card Component
struct AIResultCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Fullscreen Image View (Updated for base64)
struct FullScreenImageView: View {
    @Binding var isPresented: Bool
    var uiImage: UIImage? = nil
    var imageUrl: String? = nil
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                withAnimation(.spring()) {
                                    if scale < 1 {
                                        scale = 1
                                        lastScale = 1
                                    } else if scale > 3 {
                                        scale = 3
                                        lastScale = 3
                                    }
                                }
                            }
                    )
            } else if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .scaleEffect(scale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                        withAnimation(.spring()) {
                                            if scale < 1 {
                                                scale = 1
                                                lastScale = 1
                                            } else if scale > 3 {
                                                scale = 3
                                                lastScale = 3
                                            }
                                        }
                                    }
                            )
                    case .failure:
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text("Failed to load image")
                                .foregroundColor(.white)
                        }
                    @unknown default:
                        Color.black
                    }
                }
            } else {
                // Fallback if no image provided
                VStack(spacing: 12) {
                    Image(systemName: "photo.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.5))
                    Text("No image available")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            VStack {
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPresented = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                            Text("Close")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
    }
}

// MARK: - Diagnosis Completed View
struct DiagnosisCompletedView: View {
    var onDone: (() -> Void)? = nil
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var checkmarkOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.green.opacity(0.2), .green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(
                        LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    )
                    .scaleEffect(checkmarkScale)
                    .opacity(checkmarkOpacity)
                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            VStack(spacing: 12) {
                Text("Review Submitted Successfully")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("Your Review has been saved to the patient's medical record and the patient will be notified.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .opacity(contentOpacity)
            
            Spacer()
            
            Button {
                onDone?()
            } label: {
                Text("Back to Dashboard")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                            )
                            .shadow(color: .teal.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .opacity(contentOpacity)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                contentOpacity = 1.0
            }
        }
    }
}

// MARK: - Back Button Helper
struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                Text("Back")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .foregroundColor(LiquidGlassTheme.primaryTeal)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.92))
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white, LiquidGlassTheme.primaryTeal.opacity(0.40)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color(hex: "0F172A").opacity(0.08), radius: 6, x: 0, y: 2)
        }
    }
}
