//
//  SessionGeneratorModel.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/31/25.
//


import SwiftUI
import Foundation
import SwiftKeychainWrapper

// MARK: Session model
class SessionGeneratorModel: ObservableObject {
        
    // Add loading state
    @Published var isLoadingDrills: Bool = false
    
    let cacheManager = CacheManager.shared
    private var lastSyncTime: Date = Date()
    private let syncDebounceInterval: TimeInterval = 2.0 // 2 seconds
    var autoSaveTimer: Timer?
    var isLoggingOut = false  // Add flag to prevent caching during logout
    var isInitialLoad = false  // Add this flag
    // Track backend IDs for each group
    var groupBackendIds: [UUID: Int] = [:]
    // Track the backend ID for the liked group
    var likedGroupBackendId: Int?
    
    // Add a property to track the current session ID
    var currentSessionId: Int?
    
    private var preferenceUpdateTask: Task<Void, Never>?
    private var isOnboarding = false
    
    func schedulePreferenceUpdate() async {
        // If we're in onboarding, update immediately
        if isOnboarding {
            Task {
                do {
                    try await PreferencesUpdateService.shared.syncPreferencesWithBackend(
                        time: selectedTime,
                        equipment: selectedEquipment,
                        trainingStyle: selectedTrainingStyle,
                        location: selectedLocation,
                        difficulty: selectedDifficulty,
                        skills: selectedSkills,
                        sessionModel: self
                    )
                    print("✅ Successfully synced preferences with backend")
                } catch {
                    print("❌ Failed to sync preferences with backend: \(error)")
                }
            }
            return
        }
        
        await MainActor.run {
            isLoadingDrills = true
        }
        defer {
            Task { @MainActor in
                isLoadingDrills = false
            }
        }
        
        // Cancel any existing update task
        preferenceUpdateTask?.cancel()
        
        // Create a new task
        preferenceUpdateTask = Task {
            // Wait for 0.5 seconds to allow for multiple rapid changes
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Only proceed if the task hasn't been cancelled
            guard !Task.isCancelled else { return }
            
            // Perform the update
            do {
                try await PreferencesUpdateService.shared.syncPreferencesWithBackend(
                    time: selectedTime,
                    equipment: selectedEquipment,
                    trainingStyle: selectedTrainingStyle,
                    location: selectedLocation,
                    difficulty: selectedDifficulty,
                    skills: selectedSkills,
                    sessionModel: self
                )
                print("✅ Successfully synced preferences with backend")
            } catch {
                print("❌ Failed to sync preferences with backend: \(error)")
            }
        }
    }
    
    
    // Computed property to get the correct icon name
    func skillIconName(for skill: String) -> String {
        let normalizedSkill = skill
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "_", with: "")
        
        let skillCategory = SessionGeneratorView.skillCategories.first { category in
            let normalizedCategoryName = category.name
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "_", with: "")
            return normalizedCategoryName == normalizedSkill
        }
        return skillCategory?.icon ?? "figure.soccer"
    }
    
    
    // MARK: Filter and Skill Selection
    
    
    
    @Published var selectedTime: String? {
        didSet {
            print("[DEBUG] selectedTime changed to: \(String(describing: selectedTime))")
            if !isInitialLoad && !isLoggingOut {
                Task {
                    await schedulePreferenceUpdate()
                }
            }
            print("\(isInitialLoad) and \(isLoggingOut)")
        }
    }

    @Published var selectedEquipment: Set<String> = [] {
        didSet {
            print("[DEBUG] selectedEquipment changed to: \(selectedEquipment)")
            if !isInitialLoad && !isLoggingOut {
                Task {
                    await schedulePreferenceUpdate()
                }
            }
        }
    }

    @Published var selectedTrainingStyle: String? {
        didSet {
            print("[DEBUG] selectedTrainingStyle changed to: \(String(describing: selectedTrainingStyle))")
            if !isInitialLoad && !isLoggingOut {
                Task {
                    await schedulePreferenceUpdate()
                }
            }
        }
    }

    @Published var selectedLocation: String? {
        didSet {
            print("[DEBUG] selectedLocation changed to: \(String(describing: selectedLocation))")
            if !isInitialLoad && !isLoggingOut {
                Task {
                    await schedulePreferenceUpdate()
                }
            }
        }
    }

    @Published var selectedDifficulty: String? {
        didSet {
            print("[DEBUG] selectedDifficulty changed to: \(String(describing: selectedDifficulty))")
            if !isInitialLoad && !isLoggingOut {
                Task {
                    await schedulePreferenceUpdate()
                }
            }
        }
    }

    // update by selected skills
    @Published var selectedSkills: Set<String> = []
    @Published var originalSelectedSkills: Set<String> = []
    
    
    // MARK: Local Data Storage
    
    @Published var selectedDrills: [DrillModel] = []
    @Published var selectedDrillForEditing: EditableDrillModel?
    @Published var selectedDrill: DrillModel?
    @Published var recommendedDrills: [DrillModel] = []
    
    // Session Drills storage
    @Published var orderedSessionDrills: [EditableDrillModel] = [] {
        didSet { 
            if !isInitialLoad && !isLoggingOut {
                Task {
                    try await DataSyncService.shared.syncOrderedSessionDrills(sessionDrills: orderedSessionDrills)
                }
            }
        }
    }
    // Saved Drills storage
    @Published var savedDrills: [GroupModel] = [] {
        didSet {
//            if !isInitialLoad && !isLoggingOut {
//            }
        }
    }
    
    // Liked drills storage
    @Published var likedDrillsGroup: GroupModel = GroupModel(
        id: UUID(), // Will be properly initialized in init()
        name: "Liked Drills",
        description: "Your favorite drills",
        drills: []
        )
//    ) {
//        didSet { 
//            markAsNeedingSave(change: .likedDrills)
//        }
//    }
    
    // Saved filters storage
    @Published var allSavedFilters: [SavedFiltersModel] = [] {
        didSet {
            if !isInitialLoad && !isLoggingOut {
                Task {
                    try await SavedFiltersService.shared.syncSavedFilters(savedFilters: allSavedFilters)
                }
            }
        }
    }
    
    

    
    // Define Preferences struct for caching
    struct Preferences: Codable {
        var selectedTime: String?
        var selectedEquipment: [String]
        var selectedTrainingStyle: String?
        var selectedLocation: String?
        var selectedDifficulty: String?
        
        init(from sessionGeneratorModel: SessionGeneratorModel) {
            self.selectedTime = sessionGeneratorModel.selectedTime
            self.selectedEquipment = Array(sessionGeneratorModel.selectedEquipment)
            self.selectedTrainingStyle = sessionGeneratorModel.selectedTrainingStyle
            self.selectedLocation = sessionGeneratorModel.selectedLocation
            self.selectedDifficulty = sessionGeneratorModel.selectedDifficulty
        }
    }

    func loadInitialSession(from sessionResponse: SessionResponse) {
        Task {
            await MainActor.run {
                isLoadingDrills = true
            }
            
            print("\n🔄 Loading initial session with \(sessionResponse.drills.count) drills")
            self.currentSessionId = sessionResponse.sessionId
            print("✅ Current session ID: \(currentSessionId)")
            
            // Instead of directly setting selectedSkills, map the focus areas to their full skill strings
            let newSkills = Set(sessionResponse.focusAreas.compactMap { category in
                // Find any existing skills that match this category
                selectedSkills.first { $0.starts(with: "\(category)-") }
            })
            
            // Only update if we found matching skills
            if !newSkills.isEmpty {
                selectedSkills = newSkills
                print("✅ Updated focus areas: \(selectedSkills.joined(separator: ", "))")
            }
            
            // Clear any existing drills
            orderedSessionDrills.removeAll()
            
            // Convert API drills to app's drill models and add them to orderedDrills
            var processedCount = 0
            for apiDrill in sessionResponse.drills {
                do {
                    let drillModel = apiDrill.toDrillModel()
                    print("[Session] Drill loaded: \(drillModel.title), videoUrl: \(drillModel.videoUrl)")
                    // Create an editable drill model
                    let editableDrill = EditableDrillModel(
                        drill: drillModel,
                        setsDone: 0,
                        totalSets: drillModel.sets,
                        totalReps: drillModel.reps,
                        totalDuration: drillModel.duration,
                        isCompleted: false
                    )
                    // Add to ordered drills
                    orderedSessionDrills.append(editableDrill)
                    processedCount += 1
                }
            }
            
            print("✅ Processed \(processedCount) drills for session")

            
            await MainActor.run {
                isLoadingDrills = false
            }
        }
    }

    
    // Load preferences from backend
    func loadPreferencesFromBackend() async {
        do {
            let preferences = try await PreferencesUpdateService.shared.fetchPreferences()
            
            // Update preferences on the main thread
            await MainActor.run {
                // Convert duration to time string
                selectedTime = PreferencesUpdateService.shared.convertMinutesToTimeString(preferences.duration ?? 0)
                
                // Update equipment
                selectedEquipment = Set(preferences.availableEquipment ?? [])
                
                // Update other preferences
                selectedTrainingStyle = preferences.trainingStyle
                selectedLocation = preferences.trainingLocation
                selectedDifficulty = preferences.difficulty
                
                // Convert backend skills to frontend format
                selectedSkills = Set(preferences.targetSkills ?? [])
                
                print("✅ Successfully loaded preferences from backend")
            }
            
            // Cache the updated preferences
            cachePreferences()
        } catch {
            print("❌ Failed to load preferences from backend: \(error)")
        }
    }
    
    // Cache current preferences
    func cachePreferences() {
        let preferences = Preferences(from: self)
        cacheManager.cache(preferences, forKey: .filterGroupsCase)
        print("✅ Cached preferences")
    }

    // MARK: Default subskill mapping
    static let defaultSubskills: [String: String] = [
        "Passing": "Short passing",
        "Shooting": "Power shots",
        "Dribbling": "1v1 moves",
        "Defending": "Tackling",
        "First touch": "First touch",
        "Fitness": "Conditioning"
    ]

    @MainActor
    func prefillSelectedSkills(from onboardingData: OnboardingModel.OnboardingData) async {
        isOnboarding = true
        let skillsToImprove = onboardingData.areasToImprove
        let prefilledSubskillsAfterOnboarding = Set(skillsToImprove.compactMap { skill in
            if let subskill = SessionGeneratorModel.defaultSubskills[skill] {
                return "\(subskill)"
            }
            return nil
        })
        print("✅ Identified subskills to improve: \(prefilledSubskillsAfterOnboarding)")
        selectedSkills = prefilledSubskillsAfterOnboarding
        print("Prefilled subskills after onboarding: \(selectedSkills)")
    }
    
    @MainActor
    func prefillPreferences(from onboardingData: OnboardingModel.OnboardingData) async {
        isOnboarding = true
        // --- TIME ---
        let timeMap: [String: String] = [
            "Less than 15 minutes": "15min",
            "15-30 minutes": "30min",
            "30-60 minutes": "1h",
            "1-2 hours": "1h30",
            "More than 2 hours": "2h+"
        ]
    
        selectedTime = timeMap[onboardingData.dailyTrainingTime] ?? "30min"

        // --- EQUIPMENT ---
        let allowedEquipment = ["soccer ball", "cones", "goal"]
        let selectedEquipmentSet = Set(onboardingData.availableEquipment.map { $0.lowercased() }
            .filter { allowedEquipment.contains($0) }
            .map { $0 == "goal" ? "goal" : $0 }) // normalize
        
        // If no equipment was selected, default to soccer ball
        selectedEquipment = selectedEquipmentSet.isEmpty ? ["soccer ball"] : selectedEquipmentSet

        // --- TRAINING STYLE ---
        let styleMap: [String: String] = [
            "Beginner": "medium intensity",
            "Intermediate": "medium intensity",
            "Advanced": "high intensity",
            "Professional": "game prep",
            "Rest day": "rest day"
        ]
        selectedTrainingStyle = styleMap[onboardingData.trainingExperience] ?? "medium intensity"

        // --- LOCATION ---
        let locationMap: [String: String] = [
            "At a soccer field with goals": "location with goals",
            "At home (backyard or indoors)": "small space",
            "At a park or open field": "full field",
            "At a gym or indoor court": "medium field"
        ]
        selectedLocation = onboardingData.trainingLocation
            .compactMap { locationMap[$0] }
            .first ?? "full field"

        // --- DIFFICULTY ---
        let difficultyMap: [String: String] = [
            "Beginner": "beginner",
            "Intermediate": "intermediate",
            "Advanced": "advanced",
            "Professional": "advanced"
        ]
        selectedDifficulty = difficultyMap[onboardingData.position] ?? "medium"

        print("✅ Prefilled preferences from onboarding data:")

        // After all preferences are set, update isOnboarding to false
        isOnboarding = false
    }
    
    // Clear all user data when logging out
    func clearUserData() {
        print("\n🧹 Clearing user data...")
        
        // Cancel any pending auto-save timer
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
        

        
        // First clear all published properties
        orderedSessionDrills = []
        savedDrills = []
        likedDrillsGroup = GroupModel(
            id: getLikedDrillsUUID(), // Use user-specific UUID
            name: "Liked Drills",
            description: "Your favorite drills",
            drills: []
        )
        groupBackendIds = [:]
        likedGroupBackendId = nil
        selectedDrills = []
        allSavedFilters = []
        
        // Clear filter preferences
        selectedTime = nil
        selectedEquipment = []
        selectedTrainingStyle = nil
        selectedLocation = nil
        selectedDifficulty = nil
        selectedSkills = []
        
        print("✅ User data and cache cleared successfully")
    }
}


