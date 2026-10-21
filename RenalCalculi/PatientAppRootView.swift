import SwiftUI

struct PatientAppRootView: View {
    @StateObject var patientProfile = PatientProfile()  // ✅ ADDED
    
    @AppStorage("patientPID") private var patientPID: String = ""
    @AppStorage("patientName") private var patientName: String = ""
    @AppStorage("patientEmail") private var patientEmail: String = ""
    @AppStorage("patientPhone") private var patientPhone: String = ""
    @AppStorage("patientAge") private var patientAge: String = ""
    @AppStorage("patientGender") private var patientGender: String = ""
    @AppStorage("patientAddress") private var patientAddress: String = ""
    @AppStorage("patientWork") private var patientWork: String = ""
    
    @State private var isAppReady = false
    @State private var navigateToSelection = false
    
    var body: some View {
        ZStack {
            if !isAppReady {
                LiquidGlassLoadingView(
                    title: "Patient Health Portal",
                    subtitle: "Retrieving Renal Diagnostic Records & Medical History...",
                    badgeText: "PATIENT SECURE ACCESS",
                    icon: "heart.text.square.fill"
                )
                .onAppear { initializePatientApp() }
            } else {
                PatientDashboardView()
                    .environmentObject(patientProfile)// ✅ INJECTED HERE
                
                NavigationLink(
                    destination: UserSelectionView(),
                    isActive: $navigateToSelection
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
    
    func initializePatientApp() {
        print("🔑 Initializing Patient App - PID: \(patientPID)")
        
        if !patientPID.isEmpty {
            patientProfile.pid = patientPID
            patientProfile.name = patientName
            patientProfile.email = patientEmail
            patientProfile.phone = patientPhone
            patientProfile.age = patientAge
            patientProfile.gender = patientGender
            patientProfile.address = patientAddress
            patientProfile.work = patientWork
            
            print("✅ Patient loaded: \(patientName)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAppReady = true
            }
        }
    }
}

class PatientProfile: ObservableObject {
    @Published var pid: String = ""
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var age: String = ""
    @Published var gender: String = ""
    @Published var address: String = ""
    @Published var work: String = ""
}


#Preview {
    PatientAppRootView()
}
