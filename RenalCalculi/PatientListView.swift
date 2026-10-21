import SwiftUI

// MARK: - Patient List View (Updated Liquid Glass UI)

struct PatientListView: View {
    @AppStorage("doctorDID") private var doctorDID: String = ""
    @State private var patients: [CaseItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var searchText = ""
    @State private var selectedStatus = "All"
    
    private let statusFilters = ["All", "In-Review", "Completed", "Stones Detected"]

    private var verifiedCount: Int {
        patients.filter { $0.diagnosisConfirmed == 1 || $0.status.lowercased() == "completed" }.count
    }
    
    private var inReviewCount: Int {
        patients.filter { $0.diagnosisConfirmed == 0 && $0.status.lowercased() != "completed" }.count
    }

    private var stonesDetectedCount: Int {
        patients.filter { $0.stoneCount > 0 || $0.aiDetected }.count
    }

    private var filteredPatients: [CaseItem] {
        patients.filter { item in
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = trimmed.isEmpty ||
                item.patientName.localizedCaseInsensitiveContains(trimmed) ||
                item.id.localizedCaseInsensitiveContains(trimmed) ||
                item.pid.localizedCaseInsensitiveContains(trimmed)
            
            let matchesStatus: Bool
            if selectedStatus == "All" {
                matchesStatus = true
            } else if selectedStatus == "In-Review" {
                matchesStatus = item.diagnosisConfirmed == 0 && item.status.lowercased() != "completed"
            } else if selectedStatus == "Completed" {
                matchesStatus = item.diagnosisConfirmed == 1 || item.status.lowercased() == "completed"
            } else if selectedStatus == "Stones Detected" {
                matchesStatus = item.stoneCount > 0 || item.aiDetected
            } else {
                matchesStatus = item.status.localizedCaseInsensitiveContains(selectedStatus)
            }
            
            return matchesSearch && matchesStatus
        }
    }

    var body: some View {
        ZStack {
            // MARK: - Fluid Ambient Backdrop
            LiquidAmbientBackground()
            
            VStack(spacing: 0) {
                // MARK: - Header Bar with Caseload Summary
                headerSection
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                
                // MARK: - Search Field
                searchBarView
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                
                // MARK: - Filter Scroll Chips
                filterScrollView
                    .padding(.bottom, 12)
                
                // MARK: - Content Stream
                ZStack {
                    if isLoading {
                        loadingView
                    } else if !errorMessage.isEmpty {
                        errorView
                    } else if filteredPatients.isEmpty {
                        emptyView
                    } else {
                        patientScrollView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Assigned Cases")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("📋 PatientListView appeared - Doctor DID: \(doctorDID)")
            fetchPatients()
        }
    }

    // MARK: - Header Section with Quick Triage
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Patient Registry")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 14))
                            .foregroundColor(LiquidGlassTheme.primaryTeal)
                    }
                    
                    Text("Assigned Clinical Diagnostics & CT Scans")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    fetchPatients()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Sync")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(LiquidGlassTheme.primaryTeal)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(.secondarySystemBackground).opacity(0.8))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(LiquidGlassTheme.primaryTeal.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Caseload Metrics Triage Strip
            HStack(spacing: 8) {
                triageMetricCard(
                    title: "Total Cases",
                    value: "\(patients.count)",
                    icon: "folder.fill",
                    color: LiquidGlassTheme.primaryTeal,
                    filter: "All"
                )
                
                triageMetricCard(
                    title: "In-Review",
                    value: "\(inReviewCount)",
                    icon: "hourglass",
                    color: LiquidGlassTheme.amberWarning,
                    filter: "In-Review"
                )
                
                triageMetricCard(
                    title: "Verified",
                    value: "\(verifiedCount)",
                    icon: "checkmark.seal.fill",
                    color: LiquidGlassTheme.emeraldSuccess,
                    filter: "Completed"
                )
            }
        }
        .padding(14)
        .liquidGlass(cornerRadius: 20)
    }

    private func triageMetricCard(title: String, value: String, icon: String, color: Color, filter: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedStatus = filter
            }
        } label: {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(value)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(title)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selectedStatus == filter ? color.opacity(0.12) : Color(.secondarySystemBackground).opacity(0.45))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(selectedStatus == filter ? color.opacity(0.5) : Color.white.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Search Bar
    private var searchBarView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(LiquidGlassTheme.primaryTeal)
                .font(.system(size: 14, weight: .semibold))
            
            TextField("Search patient name, PID or Case #...", text: $searchText)
                .font(.system(size: 14))
                .foregroundColor(.primary)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - Filter Scroll View
    private var filterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(statusFilters, id: \.self) { filter in
                    let isSelected = selectedStatus == filter
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedStatus = filter
                        }
                    }) {
                        HStack(spacing: 5) {
                            if isSelected {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 5, height: 5)
                            }
                            Text(filter)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(isSelected ? .white : .primary.opacity(0.8))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    isSelected
                                        ? AnyShapeStyle(LiquidGlassTheme.gradientPrimary)
                                        : AnyShapeStyle(Color(.secondarySystemBackground).opacity(0.65))
                                )
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    isSelected
                                        ? Color.white.opacity(0.4)
                                        : Color.white.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isSelected ? LiquidGlassTheme.primaryTeal.opacity(0.3) : .clear,
                            radius: 6,
                            x: 0,
                            y: 2
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: LiquidGlassTheme.primaryTeal))
                .scaleEffect(1.4)
            
            VStack(spacing: 4) {
                Text("Syncing Clinical Registry")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("Retrieving verified patient scans and diagnostics...")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(28)
        .liquidGlass(cornerRadius: 22)
        .padding(.horizontal, 24)
    }

    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LiquidGlassTheme.coralDanger.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(LiquidGlassTheme.coralDanger)
            }
            
            Text("Clinical Registry Sync Failed")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(errorMessage)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            Button("Retry Registry Sync") {
                fetchPatients()
            }
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .background(LiquidGlassTheme.gradientPrimary)
            .clipShape(Capsule())
            .shadow(color: LiquidGlassTheme.primaryTeal.opacity(0.35), radius: 8, x: 0, y: 3)
        }
        .padding(26)
        .liquidGlass(cornerRadius: 22)
        .padding(.horizontal, 20)
    }

    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LiquidGlassTheme.primaryTeal.opacity(0.12))
                    .frame(width: 64, height: 64)
                Image(systemName: "folder.badge.questionmark")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(LiquidGlassTheme.primaryTeal)
            }
            
            Text(searchText.isEmpty ? "No Assigned Cases Found" : "No Matching Cases")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(searchText.isEmpty ? "Assigned clinical scans will automatically populate in your doctor workspace." : "Try adjusting your search criteria or triage filters.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(28)
        .liquidGlass(cornerRadius: 22)
        .padding(.horizontal, 20)
    }

    // MARK: - Patients Scroll View
    private var patientScrollView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(filteredPatients) { patient in
                    NavigationLink {
                        CaseReviewView(caseItem: patient)
                    } label: {
                        PatientRow(patient: patient)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Fetch Patients (Backend Preserved)
    func fetchPatients() {
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/get_cases.php") else {
            errorMessage = "Invalid server URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["doctor_id": doctorDID]
        request.httpBody = try? JSONEncoder().encode(body)

        print("📤 Fetching cases for Doctor: \(doctorDID)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ Error:", error)
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    print("❌ No data")
                    return
                }

                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("📥 Cases API Response:", rawResponse)
                }

                do {
                    let decoded = try JSONDecoder().decode([String: [CaseItem]].self, from: data)
                    self.patients = decoded["cases"] ?? []
                    print("✅ Loaded \(self.patients.count) cases")
                } catch {
                    self.errorMessage = "Failed to parse response"
                    print("❌ Decode error:", error)
                }
            }
        }.resume()
    }
}

// MARK: - Patient Row Component (Liquid Glass)

struct PatientRow: View {
    let patient: CaseItem

    private var isConfirmed: Bool {
        patient.diagnosisConfirmed == 1 || patient.status.lowercased() == "completed"
    }

    private var hasCalculi: Bool {
        patient.stoneCount > 0 || patient.aiDetected
    }

    var body: some View {
        HStack(spacing: 14) {
            // Patient Avatar Medallion
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isConfirmed
                                ? [LiquidGlassTheme.emeraldSuccess.opacity(0.22), LiquidGlassTheme.primaryTeal.opacity(0.12)]
                                : [LiquidGlassTheme.softAzure.opacity(0.25), LiquidGlassTheme.vibrantCyan.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
                    )
                    .shadow(
                        color: isConfirmed ? LiquidGlassTheme.emeraldSuccess.opacity(0.2) : LiquidGlassTheme.primaryTeal.opacity(0.15),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
                
                Image(systemName: isConfirmed ? "checkmark.circle.fill" : "person.crop.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(isConfirmed ? LiquidGlassTheme.emeraldSuccess : LiquidGlassTheme.primaryTeal)
            }

            // Patient Clinical Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(patient.patientName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if !patient.pid.isEmpty {
                        Text("PID: \(patient.pid)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(LiquidGlassTheme.primaryTeal)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(LiquidGlassTheme.primaryTeal.opacity(0.12))
                            )
                    }
                }
                
                HStack(spacing: 8) {
                    Text("Case #\(patient.id)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    if hasCalculi {
                        HStack(spacing: 3) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 9))
                            Text("\(patient.stoneCount) Calculus Detected")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(LiquidGlassTheme.coralDanger)
                    } else {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 9))
                            Text("Clear CT Scan")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(LiquidGlassTheme.emeraldSuccess)
                    }
                }
            }

            Spacer()

            // Status Pill + Action Chevron
            VStack(alignment: .trailing, spacing: 8) {
                LiquidGlassPill(
                    title: isConfirmed ? "Verified" : "In-Review",
                    icon: isConfirmed ? "checkmark.seal.fill" : "hourglass",
                    color: isConfirmed ? LiquidGlassTheme.emeraldSuccess : LiquidGlassTheme.amberWarning,
                    isGlowing: true
                )
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
            }
        }
        .padding(14)
        .liquidGlass(cornerRadius: 18)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        PatientListView()
    }
}
