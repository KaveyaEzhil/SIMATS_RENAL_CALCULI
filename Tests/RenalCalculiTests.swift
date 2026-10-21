import Foundation

@main
struct RenalCalculiTestRunner {
    static var totalTests = 0
    static var passedTests = 0
    static var failedTests = 0

    static func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "", file: String = #file, line: Int = #line) {
        totalTests += 1
        if actual == expected {
            passedTests += 1
            print("  ✅ PASS: \(message.isEmpty ? "\(actual) == \(expected)" : message)")
        } else {
            failedTests += 1
            print("  ❌ FAIL: \(message) - expected: [\(expected)], got: [\(actual)] at line \(line)")
        }
    }

    static func assertTrue(_ condition: Bool, _ message: String = "", file: String = #file, line: Int = #line) {
        totalTests += 1
        if condition {
            passedTests += 1
            print("  ✅ PASS: \(message.isEmpty ? "Condition is true" : message)")
        } else {
            failedTests += 1
            print("  ❌ FAIL: \(message) - expected true at line \(line)")
        }
    }

    static func main() {
        print("==========================================")
        print("🧪 Running SIMATS Renal Calculi Unit Tests")
        print("==========================================")

        // MARK: - Test 1: ServiceAPI Endpoint Validation
        print("\n--- Test Suite 1: ServiceAPI Configuration ---")
        assertTrue(ServiceAPI.baseURL.hasPrefix("http"), "Base URL should start with http")
        assertTrue(ServiceAPI.doctorLogin.hasPrefix(ServiceAPI.baseURL), "Doctor login endpoint should use baseURL")
        assertTrue(ServiceAPI.patientLogin.hasPrefix(ServiceAPI.baseURL), "Patient login endpoint should use baseURL")
        assertTrue(ServiceAPI.diagnosis.hasPrefix(ServiceAPI.baseURL), "Diagnosis endpoint should use baseURL")
        assertTrue(ServiceAPI.getHistory.hasPrefix(ServiceAPI.baseURL), "History endpoint should use baseURL")

        // MARK: - Test 2: CaseItem Computed Properties
        print("\n--- Test Suite 2: CaseItem Computed Properties ---")
        let sampleCase = CaseItem(
            id: "CASE001",
            patientEmail: "test@example.com",
            patientName: "John Doe",
            age: 45,
            gender: "Male",
            doctor: "Dr. Smith",
            stoneCount: 2,
            stoneSizes: ["4.5mm", "7.2 mm"],
            stoneLocations: ["Left Kidney - Lower Pole", "Left Kidney - Mid Pole"],
            image: "scan123.jpg",
            pid: "PID001",
            diagnosisNotes: "Calculi observed",
            diagnosisConfirmed: 0
        )

        assertEqual(sampleCase.status, "pending", "Unconfirmed case should be pending")
        assertTrue(sampleCase.aiDetected, "Case with stones should have aiDetected == true")
        assertEqual(sampleCase.aiCount, 2, "AI count should equal stone count")
        assertEqual(sampleCase.aiLocation, "Left Kidney - Lower Pole", "Primary AI location should match first location")
        assertEqual(sampleCase.aiSizeMM, 7.2, "Largest stone size should be 7.2")
        assertEqual(sampleCase.averageStoneSize, 5.85, "Average stone size should be 5.85")
        assertTrue(sampleCase.fullImageUrl.contains("scan123.jpg"), "Full image URL should contain image path")

        // MARK: - Test 3: CaseItem Completed State
        print("\n--- Test Suite 3: CaseItem Completed State ---")
        let completedCase = sampleCase.withUpdatedDiagnosis(notes: "Confirmed kidney stones", confirmed: 1)
        assertEqual(completedCase.status, "completed", "Confirmed case should have status completed")
        assertEqual(completedCase.diagnosisConfirmed, 1, "diagnosisConfirmed should be 1")
        assertEqual(completedCase.diagnosisNotes, "Confirmed kidney stones", "Diagnosis notes should be updated")

        // MARK: - Test 4: CaseItem JSON Codable Roundtrip
        print("\n--- Test Suite 4: CaseItem JSON Serialization ---")
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(sampleCase)
            let decoder = JSONDecoder()
            let decodedCase = try decoder.decode(CaseItem.self, from: data)
            assertEqual(decodedCase.id, sampleCase.id, "Decoded id should match")
            assertEqual(decodedCase.patientEmail, sampleCase.patientEmail, "Decoded email should match")
            assertEqual(decodedCase.stoneCount, sampleCase.stoneCount, "Decoded stone count should match")
            assertEqual(decodedCase.stoneSizes, sampleCase.stoneSizes, "Decoded stone sizes should match")
        } catch {
            failedTests += 1
            print("  ❌ FAIL: JSON Encoding/Decoding threw error: \(error)")
        }

        // MARK: - Test 5: DoctorProfile Change Tracking
        print("\n--- Test Suite 5: DoctorProfile Logic ---")
        let profile = DoctorProfile()
        profile.name = "Dr. Alice"
        profile.email = "alice@hospital.org"
        profile.saveOriginalData()
        assertTrue(!profile.hasChanges(), "Profile should have no changes after saveOriginalData")

        profile.name = "Dr. Alice Bob"
        assertTrue(profile.hasChanges(), "Profile should report changes after name modification")

        profile.name = "Dr. Alice"
        assertTrue(!profile.hasChanges(), "Profile should report no changes after reverting name")

        // MARK: - Summary
        print("\n==========================================")
        print("📊 Test Summary: \(passedTests)/\(totalTests) Passed, \(failedTests) Failed")
        print("==========================================")

        if failedTests > 0 {
            exit(1)
        } else {
            print("🎉 All SIMATS Renal Calculi Unit Tests Passed Successfully!\n")
            exit(0)
        }
    }
}
