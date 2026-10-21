import SwiftUI

// MARK: - All Cases View with Enhanced UI/UX Design - FIXED LOOPING ISSUE - STAT CARDS AS NAVIGATION

struct AllCasesView: View {
    @State private var allCases: [CaseItem] = []
    @State private var inReviewCases: [CaseItem] = []
    @State private var completedCases: [CaseItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var doctorDID: String = ""
    @State private var selectedTab: CaseTab = .all
    @State private var searchText = ""
    
    // ✅ FIX: Add flag to prevent repeated fetches
    @State private var hasLoadedOnce = false
    
    enum CaseTab: String, CaseIterable {
        case all = "All"
        case inReview = "In-review"
        case completed = "Completed"
    }
    
    private var filteredCases: [CaseItem] {
        let baseList: [CaseItem]
        switch selectedTab {
        case .all:
            baseList = allCases
        case .inReview:
            baseList = inReviewCases
        case .completed:
            baseList = completedCases
        }
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return baseList
        } else {
            return baseList.filter {
                $0.patientName.lowercased().contains(trimmed) ||
                $0.id.lowercased().contains(trimmed) ||
                $0.pid.lowercased().contains(trimmed)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Liquid Ambient Canvas
                LiquidAmbientBackground()
                
                VStack(spacing: 0) {
                    // MARK: - Liquid Glass Header with Caseload Triage
                    VStack(spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text("Patient Registry")
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Image(systemName: "cross.case.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                                }
                                
                                Text("Diagnostic Scans & Physician Reviews")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            LiquidGlassPill(
                                title: "\(allCases.count) TOTAL",
                                icon: "chart.bar.doc.horizontal",
                                color: LiquidGlassTheme.primaryTeal
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        
                        // Search Bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(LiquidGlassTheme.primaryTeal)
                            
                            TextField("Search by patient name or ID...", text: $searchText)
                                .font(.system(size: 14))
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray.opacity(0.6))
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.systemBackground).opacity(0.65))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // STATS FILTER TABS (Clickable)
                        HStack(spacing: 10) {
                            // All Cases Tab
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = .all
                                }
                            } label: {
                                StatsCard(
                                    label: "Total",
                                    value: allCases.count,
                                    icon: "folder.fill",
                                    color: LiquidGlassTheme.primaryTeal,
                                    isSelected: selectedTab == .all
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // In-Review Tab
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = .inReview
                                }
                            } label: {
                                StatsCard(
                                    label: "In-Review",
                                    value: inReviewCases.count,
                                    icon: "hourglass.circle.fill",
                                    color: LiquidGlassTheme.amberWarning,
                                    isSelected: selectedTab == .inReview
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // Completed Tab
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = .completed
                                }
                            } label: {
                                StatsCard(
                                    label: "Completed",
                                    value: completedCases.count,
                                    icon: "checkmark.circle.fill",
                                    color: LiquidGlassTheme.emeraldSuccess,
                                    isSelected: selectedTab == .completed
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    .liquidGlass(cornerRadius: 22, shadowRadius: 14)
                    .padding(12)
                    
                    // MARK: - Cases Content Area
                    ZStack {
                        if isLoading {
                            LoadingView()
                        } else if !errorMessage.isEmpty {
                            ErrorView(message: errorMessage) {
                                fetchCases()
                            }
                        } else if filteredCases.isEmpty {
                            EmptyCasesView(tab: selectedTab)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredCases, id: \.id) { caseItem in
                                        NavigationLink {
                                            CaseReviewView(caseItem: caseItem)
                                        } label: {
                                            RecentCaseRow(caseItem: caseItem)
                                                .transition(.opacity.combined(with: .scale))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(12)
                                .padding(.bottom, 160)
                            }
                            .scrollIndicators(.hidden)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                            .refreshable {
                                await refreshCases()
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            // ✅ FIX: Only fetch once on initial load
            .onAppear {
                if !hasLoadedOnce {
                    hasLoadedOnce = true
                    fetchCases()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Helper Functions
    private func countForTab(_ tab: CaseTab) -> Int {
        switch tab {
        case .all: return allCases.count
        case .inReview: return inReviewCases.count
        case .completed: return completedCases.count
        }
    }
    
    // MARK: - Fetch & Categorize Cases
    private func fetchCases() {
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/get_pending_reviews.php") else {
            errorMessage = "Invalid server URL"
            isLoading = false
            return
        }
        
        print("📤 Fetching cases from: \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ Network Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    print("❌ No data received from server")
                    return
                }
                
                let rawResponse = String(data: data, encoding: .utf8) ?? "nil"
                print("📥 Raw Response: \(rawResponse)")
                
                struct APIResponse: Codable {
                    let success: Bool
                    let cases: [CaseItem]?
                }
                
                do {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    guard let cases = response.cases else {
                        print("⚠️ No cases in response")
                        self.allCases = []
                        self.inReviewCases = []
                        self.completedCases = []
                        return
                    }
                    
                    print("\n📋 === CATEGORIZING CASES ===")
                    print("Total cases received: \(cases.count)")
                    
                    // ✅ Categorize by diagnosisConfirmed flag
                    self.allCases = cases
                    self.inReviewCases = cases.filter { caseItem in
                        let isInReview = caseItem.diagnosisConfirmed == 0
                        print(" Case: \(caseItem.patientName)")
                        print(" - diagnosisConfirmed: \(caseItem.diagnosisConfirmed)")
                        print(" - Status: \(caseItem.status)")
                        print(" - aiCount: \(caseItem.aiCount)") // ✅ Debug stone count
                        print(" - Category: \(isInReview ? "IN-REVIEW ⏳" : "COMPLETED ✅")")
                        return isInReview
                    }
                    
                    self.completedCases = cases.filter { caseItem in
                        caseItem.diagnosisConfirmed == 1
                    }
                    
                    print("\n✅ Categorization Complete:")
                    print(" - In-review (diagnosisConfirmed=0): \(self.inReviewCases.count)")
                    print(" - Completed (diagnosisConfirmed=1): \(self.completedCases.count)")
                    print("=" + String(repeating: "=", count: 39) + "\n")
                    
                } catch {
                    self.errorMessage = "Failed to parse data: \(error.localizedDescription)"
                    print("❌ Decode error: \(error)")
                }
            }
        }.resume()
    }
    
    private func refreshCases() async {
        return await withCheckedContinuation { continuation in
            fetchCases()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                continuation.resume()
            }
        }
    }
}

// MARK: - Liquid Glass Recent Case Row
struct RecentCaseRow: View {
    let caseItem: CaseItem
    @State private var isHovered = false
    
    var statusBadge: (label: String, color: Color, icon: String) {
        if caseItem.diagnosisConfirmed == 1 {
            return (label: "Completed", color: LiquidGlassTheme.emeraldSuccess, icon: "checkmark.seal.fill")
        } else {
            return (label: "In-Review", color: LiquidGlassTheme.amberWarning, icon: "hourglass")
        }
    }
    
    // Helper to format stone sizes for display
    var formattedStoneSizes: String {
        guard !caseItem.stoneSizes.isEmpty else { return "—" }
        let formattedSizes = caseItem.stoneSizes.map { sizeString in
            let cleanSize = sizeString.replacingOccurrences(of: "mm", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let size = Double(cleanSize) {
                return String(format: "%.1f", size)
            }
            return cleanSize
        }
        if formattedSizes.count <= 3 {
            return formattedSizes.joined(separator: ", ") + " mm"
        } else {
            let firstTwo = Array(formattedSizes.prefix(2))
            return firstTwo.joined(separator: ", ") + " mm (+\(formattedSizes.count - 2) more)"
        }
    }
    
    var largestStoneSize: String {
        guard !caseItem.stoneSizes.isEmpty else { return "—" }
        var maxSize: Double = 0
        for sizeString in caseItem.stoneSizes {
            let cleanSize = sizeString.replacingOccurrences(of: "mm", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let size = Double(cleanSize), size > maxSize {
                maxSize = size
            }
        }
        return String(format: "%.1f mm", maxSize)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header Row: Patient Profile + Status Pill
            HStack(spacing: 12) {
                // Patient Medallion
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    LiquidGlassTheme.primaryTeal.opacity(0.2),
                                    LiquidGlassTheme.vibrantCyan.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.7), lineWidth: 1)
                        )
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(caseItem.patientName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Text("ID: \(caseItem.id)")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text("\(caseItem.age) yrs, \(caseItem.gender)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status Pill
                LiquidGlassPill(
                    title: statusBadge.label,
                    icon: statusBadge.icon,
                    color: statusBadge.color,
                    isGlowing: true
                )
            }
            
            // Stone Findings & Telemetry Chips
            HStack(spacing: 8) {
                if caseItem.aiDetected {
                    DetectionBox(
                        icon: "checkmark.circle.fill",
                        text: "\(caseItem.stoneCount) Stones",
                        color: LiquidGlassTheme.coralDanger
                    )
                    
                    DetectionBox(
                        icon: "ruler",
                        text: "Max \(largestStoneSize)",
                        color: LiquidGlassTheme.primaryTeal
                    )
                } else {
                    DetectionBox(
                        icon: "checkmark.shield.fill",
                        text: "No Stones Found",
                        color: LiquidGlassTheme.emeraldSuccess
                    )
                }
                
                DetectionBox(
                    icon: "sparkles",
                    text: "\(caseItem.aiScore)% Match",
                    color: LiquidGlassTheme.purpleAccent
                )
                
                Spacer()
            }
            
            // Locations Chips (if present)
            if caseItem.aiDetected && !caseItem.stoneLocations.isEmpty {
                let uniqueLocations = Array(Set(caseItem.stoneLocations))
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(LiquidGlassTheme.primaryTeal)
                    
                    Text(uniqueLocations.joined(separator: ", "))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.primary.opacity(0.8))
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.4))
                )
            }
            
            // Interaction Footer: Doctor Action Trigger
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: caseItem.diagnosisConfirmed == 1 ? "checkmark.circle.fill" : "stethoscope")
                        .font(.system(size: 12))
                        .foregroundColor(caseItem.diagnosisConfirmed == 1 ? LiquidGlassTheme.emeraldSuccess : LiquidGlassTheme.amberWarning)
                    
                    Text(caseItem.diagnosisConfirmed == 1 ? "Diagnosis Confirmed & Transmitted" : "Awaiting Doctor Confirmation")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(caseItem.diagnosisConfirmed == 1 ? LiquidGlassTheme.emeraldSuccess : LiquidGlassTheme.amberWarning)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Review Case")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(LiquidGlassTheme.primaryTeal)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .liquidGlass(cornerRadius: 20, shadowRadius: 10)
        .onHover { hovered in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovered
            }
        }
    }
}

// MARK: - Detail Box Component
struct DetailBox: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(color.opacity(0.2), lineWidth: 0.8)
        )
    }
}

// MARK: - Detection Box Component
struct DetectionBox: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            
            Text(text)
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .foregroundColor(color)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
        )
        .overlay(
            Capsule()
                .strokeBorder(color.opacity(0.25), lineWidth: 0.8)
        )
    }
}

// MARK: - Stat Card Component (NOW CLICKABLE FOR NAVIGATION)
struct StatsCard: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(isSelected ? 0.25 : 0.15))
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                }
            }
            
            Text("\(value)")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? color.opacity(0.14) : Color.white.opacity(0.45))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            isSelected ? color : Color.white,
                            isSelected ? color.opacity(0.5) : color.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isSelected ? 1.6 : 1.0
                )
        )
        .shadow(color: isSelected ? color.opacity(0.25) : Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

// MARK: - Loading View with Enhanced Animation
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.teal.opacity(0.2), lineWidth: 10)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.teal, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            }
            .shadow(color: Color.teal.opacity(0.3), radius: 8, x: 0, y: 2)
            
            VStack(spacing: 6) {
                Text("Loading cases...")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Please wait while we fetch your cases")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxHeight: .infinity)
        .padding(24)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Empty Cases View
struct EmptyCasesView: View {
    let tab: AllCasesView.CaseTab
    @State private var isAnimating = false
    
    var imageName: String {
        switch tab {
        case .all: return "tray"
        case .inReview: return "hourglass"
        case .completed: return "checkmark.circle"
        }
    }
    
    var title: String {
        switch tab {
        case .all: return "No cases yet"
        case .inReview: return "No in-review cases"
        case .completed: return "No completed cases"
        }
    }
    
    var subtitle: String {
        switch tab {
        case .all: return "Cases will appear here when available."
        case .inReview: return "All cases have been reviewed."
        case .completed: return "No cases have been completed yet."
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.teal.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: imageName)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.teal)
            }
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            
            Text(title)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxHeight: .infinity)
        .padding(24)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            
            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    retryAction()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text("Retry")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.teal, Color.teal.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.teal.opacity(0.3), radius: 6, x: 0, y: 2)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .onLongPressGesture(minimumDuration: 0.01, perform: {}, onPressingChanged: { isPressing in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = isPressing
                    }
                })
            }
        }
        .frame(maxHeight: .infinity)
        .padding(24)
    }
}

// MARK: - Preview
#Preview {
    AllCasesView()
}
