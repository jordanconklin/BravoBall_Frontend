////
////  BravoBall.swift
////  BravoBall
////
////  Created by Jordan on 5/16/25.
////
//
//import XCTest
//@testable import BravoBall
//
//final class BravoBallTests: XCTestCase {
//    var sessionGeneratorModel: SessionGeneratorModel!
//    var mockAppModel: MainAppModel!
//    
//    override func setUpWithError() throws {
//        // Create a mock MainAppModel
//        mockAppModel = MainAppModel()
//        
//        // Create mock onboarding data
//        var mockOnboardingData = OnboardingModel.OnboardingData()
//        mockOnboardingData.strengths = ["Passing-short_passing", "Shooting-power_shots"]
//        mockOnboardingData.dailyTrainingTime = "30"
//        mockOnboardingData.availableEquipment = ["Soccer ball", "Cones"]
//        mockOnboardingData.trainingExperience = "High Intensity"
//        mockOnboardingData.trainingLocation = ["Outdoor"]
//        mockOnboardingData.position = "Beginner"
//        // Add any other fields as needed for your test
//        
//        // Initialize SessionGeneratorModel with mock data
//        sessionGeneratorModel = SessionGeneratorModel(appModel: mockAppModel, onboardingData: mockOnboardingData)
//    }
//    
//    override func tearDownWithError() throws {
//        sessionGeneratorModel = nil
//        mockAppModel = nil
//    }
//    
//    func testSessionLoadingAfterOnboarding() async throws {
//        // Create a mock session response
//        let mockSessionResponse = SessionResponse(
//            sessionId: 1,
//            totalDuration: 35,
//            focusAreas: ["Passing", "Shooting"],
//            drills: [
//                DrillResponse(
//                    id: 1,
//                    title: "Short Passing Drill",
//                    description: "Practice accurate short passes",
//                    duration: 15,
//                    intensity: "High",
//                    difficulty: "Beginner",
//                    equipment: ["Soccer ball"],
//                    suitableLocations: ["Outdoor"],
//                    instructions: ["Keep the ball on the ground"],
//                    tips: ["Use inside of foot"],
//                    type: "Passing",
//                    sets: 4,
//                    reps: 10,
//                    rest: 30,
//                    primarySkill: DrillResponse.Skill(category: "Passing", subSkill: "short_passing"),
//                    secondarySkills: nil
//                ),
//                DrillResponse(
//                    id: 2,
//                    title: "Power Shot Practice",
//                    description: "Work on powerful shots",
//                    duration: 20,
//                    intensity: "High",
//                    difficulty: "Beginner",
//                    equipment: ["Soccer ball"],
//                    suitableLocations: ["Outdoor"],
//                    instructions: ["Plant foot beside ball"],
//                    tips: ["Follow through"],
//                    type: "Shooting",
//                    sets: 3,
//                    reps: 5,
//                    rest: 45,
//                    primarySkill: DrillResponse.Skill(category: "Shooting", subSkill: "power_shots"),
//                    secondarySkills: nil
//                )
//            ]
//        )
//        
//        // Load the mock session
//        sessionGeneratorModel.loadInitialSession(from: mockSessionResponse)
//        
//        // Verify that the session was loaded correctly
//        await MainActor.run {
//            XCTAssertNotNil(sessionGeneratorModel.currentSessionId, "Session ID should be set")
//            XCTAssertEqual(sessionGeneratorModel.currentSessionId, 1, "Session ID should match mock data")
//            XCTAssertFalse(sessionGeneratorModel.orderedSessionDrills.isEmpty, "Ordered drills should not be empty")
//            XCTAssertEqual(sessionGeneratorModel.orderedSessionDrills.count, 2, "Should have 2 drills loaded")
//            
//            // Verify that the skills were properly set
//            XCTAssertFalse(sessionGeneratorModel.selectedSkills.isEmpty, "Selected skills should not be empty")
//            XCTAssertTrue(sessionGeneratorModel.selectedSkills.contains("Passing-short_passing"), "Should contain short passing skill")
//            XCTAssertTrue(sessionGeneratorModel.selectedSkills.contains("Shooting-power_shots"), "Should contain power shots skill")
//            
//            // Verify that the drills match the mock data
//            let firstDrill = sessionGeneratorModel.orderedSessionDrills[0]
//            XCTAssertEqual(firstDrill.drill.title, "Short Passing Drill", "First drill title should match")
//            XCTAssertEqual(firstDrill.drill.skill, "Passing", "First drill skill should match")
//            
//            let secondDrill = sessionGeneratorModel.orderedSessionDrills[1]
//            XCTAssertEqual(secondDrill.drill.title, "Power Shot Practice", "Second drill title should match")
//            XCTAssertEqual(secondDrill.drill.skill, "Shooting", "Second drill skill should match")
//        }
//    }
//    
//    func testEmptySessionResponse() async throws {
//        // Create an empty session response
//        let emptySessionResponse = SessionResponse(
//            sessionId: 1,
//            totalDuration: 0,
//            focusAreas: [],
//            drills: []
//        )
//        
//        // Load the empty session
//        sessionGeneratorModel.loadInitialSession(from: emptySessionResponse)
//        
//        // Verify that the session was loaded correctly even though it's empty
//        XCTAssertNotNil(sessionGeneratorModel.currentSessionId, "Session ID should be set")
//        XCTAssertEqual(sessionGeneratorModel.currentSessionId, 1, "Session ID should match mock data")
//        XCTAssertTrue(sessionGeneratorModel.orderedSessionDrills.isEmpty, "Ordered drills should be empty")
//    }
//}
//
//
