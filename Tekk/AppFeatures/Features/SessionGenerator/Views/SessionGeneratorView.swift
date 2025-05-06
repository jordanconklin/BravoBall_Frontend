//
//  testSesGenView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/22/25.
//

import SwiftUI
import RiveRuntime

// Add the SessionResponse model definition directly in this file
struct SessionResponse: Codable {
    let sessionId: Int?
    let totalDuration: Int
    let focusAreas: [String]
    let drills: [DrillResponse]
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case totalDuration = "total_duration"
        case focusAreas = "focus_areas"
        case drills
    }
}



// Add the DrillResponse model definition
//TODO: have backend send othe rneeded data types (e.g. thumbnail URL) it is accepting 
struct DrillResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let duration: Int
    let intensity: String
    let difficulty: String
    let equipment: [String]
    let suitableLocations: [String]
    let instructions: [String]
    let tips: [String]
    let type: String
    let sets: Int?  // Make sets optional to handle null values
    let reps: Int?  // Make reps optional to handle null values
    let rest: Int?
    let primarySkill: DrillResponse.Skill?
    let secondarySkills: [DrillResponse.Skill]?
    
    struct Skill: Codable, Hashable {
            let category: String
            let subSkill: String
            
            enum CodingKeys: String, CodingKey {
                case category
                case subSkill = "sub_skill"
            }
        }
    
    // enums to handle sanke_case and camelCase differences from frontend and backend
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case duration
        case intensity
        case difficulty
        case equipment
        case suitableLocations = "suitable_locations"
        case instructions
        case tips
        case type
        case sets
        case reps
        case rest
        case primarySkill = "primary_skill"
        case secondarySkills = "secondary_skills"
    }
    
    // Convert API response to local DrillModel
    func toDrillModel() -> DrillModel {
        // Get the primary skill category, defaulting to the type if not available
        let skillCategory = primarySkill?.category ?? type
        
        // Collect all sub-skills from both primary and secondary skills
        var allSubSkills: [String] = []
        if let primarySubSkill = primarySkill?.subSkill {
            allSubSkills.append(primarySubSkill)
        }
        if let secondarySkills = secondarySkills {
            allSubSkills.append(contentsOf: secondarySkills.map { $0.subSkill })
        }
        
        return DrillModel(
            id: UUID(),  // Generate a new UUID since we can't convert an Int to UUID
            backendId: id, // Store the backend ID from the API
            title: title,
            skill: skillCategory,
            subSkills: allSubSkills,
            sets: sets ?? 0,
            reps: reps ?? 0,
            duration: duration,
            description: description,
            tips: tips,
            equipment: equipment,
            trainingStyle: intensity,
            difficulty: difficulty
        )
    }
    
    // Custom initializer to handle decoding with null values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields with default values if missing or null
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Unnamed Drill"
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        
        // Handle null durations
        if let durationValue = try? container.decode(Int.self, forKey: .duration) {
            duration = durationValue
        } else {
            duration = 10 // Default value
        }
        
        intensity = try container.decodeIfPresent(String.self, forKey: .intensity) ?? "medium"
        difficulty = try container.decodeIfPresent(String.self, forKey: .difficulty) ?? "beginner"
        
        // Handle array fields
        equipment = try container.decodeIfPresent([String].self, forKey: .equipment) ?? []
        suitableLocations = try container.decodeIfPresent([String].self, forKey: .suitableLocations) ?? []
        instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
        tips = try container.decodeIfPresent([String].self, forKey: .tips) ?? []
        
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? "other"
        
        
        // Optional fields
        sets = try container.decodeIfPresent(Int.self, forKey: .sets)
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
        rest = try container.decodeIfPresent(Int.self, forKey: .rest)
        
        primarySkill = try container.decodeIfPresent(Skill.self, forKey: .primarySkill)
        secondarySkills = try container.decodeIfPresent([Skill].self, forKey: .secondarySkills)
    }
    
    // Standard initializer for creating instances directly
    init(id: Int, title: String, description: String, duration: Int, intensity: String, difficulty: String, equipment: [String], suitableLocations: [String], instructions: [String], tips: [String], type: String, sets: Int?, reps: Int?, rest: Int?, primarySkill: Skill?, secondarySkills: [Skill]?) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.intensity = intensity
        self.difficulty = difficulty
        self.equipment = equipment
        self.suitableLocations = suitableLocations
        self.instructions = instructions
        self.tips = tips
        self.type = type
        self.sets = sets
        self.reps = reps
        self.rest = rest
        self.primarySkill = primarySkill
        self.secondarySkills = secondarySkills
    }
    
    // Map API skill types to app skill types
    private func mapSkillType(_ apiType: String) -> String {
        let skillMap = [
            "passing": "Passing",
            "shooting": "Shooting",
            "dribbling": "Dribbling",
            "first_touch": "First touch",
            "fitness": "Fitness",
            "defending": "Defending",
            "set_based": "Set-based",
            "reps_based": "Reps-based"
        ]
        
        return skillMap[apiType.lowercased()] ?? apiType
    }
}

struct SessionGeneratorView: View {
    @ObservedObject var model: OnboardingModel
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Environment(\.viewGeometry) var geometry
    
    @State private var savedFiltersName: String  = ""
    @State private var searchSkillsText: String = ""
    

        
    
    // MARK: Main view
    var body: some View {
        ZStack(alignment: .bottom) {
            // Sky background color
            Color(hex:"bef1fa")
                .ignoresSafeArea()

            homePage
                .frame(maxWidth: geometry.size.width)
                .frame(maxWidth: .infinity)


            // Golden button
            if sessionReady() {
                goldenButton
                    .frame(maxWidth: min(geometry.size.width - 40, appModel.layout.buttonMaxWidth))
            }
            
            // Prompt to save filter
            if appModel.viewState.showSaveFiltersPrompt {
                saveFiltersPrompt
            }
        }
        // Sheet pop-up for each filter
        .sheet(item: $appModel.selectedFilter) { type in
            FilterSheet(
                appModel: appModel,
                sessionModel: sessionModel,
                type: type
            ) {
                appModel.selectedFilter = nil
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(appModel.layout.sheetHeight)])
            .frame(width: geometry.size.width)
        }
        // Sheet pop-up for saved filters
        .sheet(isPresented: $appModel.viewState.showSavedFilters) {
            SavedFiltersSheet(
                appModel: appModel,
                sessionModel: sessionModel,
                dismiss: { appModel.viewState.showSavedFilters = false }
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(appModel.layout.sheetHeight)])
            .frame(width: geometry.size.width)
        }
        // Sheet pop-up for filter option button
        .sheet(isPresented: $appModel.viewState.showFilterOptions) {
            FilterOptions(
                appModel: appModel,
                sessionModel: sessionModel
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(appModel.layout.sheetHeight)])
            .frame(width: geometry.size.width)
        }
    }
    
    // MARK: Home page
    private var homePage: some View {
            ZStack(alignment: .top) {
                // Where session begins, behind home page
                AreaBehindHomePage(appModel: appModel, sessionModel: sessionModel)
                    .frame(maxWidth: geometry.size.width)
                
                if appModel.viewState.showHomePage {
                    VStack(spacing: 0) {
                        // Header with Bravo and message bubble
                        HStack(alignment: .center) {
                            
                            Spacer()
                            
                            // Bravo
                            RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 3")
                                .view()
                                .frame(width: 90, height: 90)
                                .padding(.leading, geometry.size.width * 0.1)
                            
                            if appModel.viewState.showPreSessionTextBubble {
                                preSessionMessageBubble
                                    .padding(.leading, 5)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, geometry.safeAreaInsets.top)
                        
                        // ZStack for rounded corner
                        ZStack {
                            
                            // Rounded corner
                            RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                                .fill(Color.white)
                                .edgesIgnoringSafeArea(.bottom)
                            
                            // White part of home page
                            VStack(alignment: .center, spacing: 5) {
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    SkillSearchBar(appModel: appModel, sessionModel: sessionModel, searchText: $searchSkillsText)
                                        .padding(.top, 3)
                                    
                                    Spacer()
                                }
                                .padding(.top, 5)
                                .frame(maxWidth: appModel.layout.adaptiveWidth(geometry))
                                
                                // If skills search bar is selected
                                if appModel.viewState.showSkillSearch {
                                    
                                    // New view for searching skills
                                    SearchSkillsView(
                                        appModel: appModel,
                                        sessionModel: sessionModel,
                                        searchText: $searchSkillsText
                                    )
                                    
                                // If skills search bar is not selected
                                } else {
                                    filterScrollView
                                        .frame(width: geometry.size.width)
                                    
                                    // Main content
                                    ScrollView(showsIndicators: false) {
                                        VStack(spacing: appModel.layout.standardSpacing) {
                                            
                                            
                                            GeneratedDrillsSection(appModel: appModel, sessionModel: sessionModel)
                                                .padding(.horizontal, appModel.layout.contentMinPadding)
                                            
                                            if sessionModel.selectedSkills.isEmpty {
                                                RecommendedDrillsSection(appModel: appModel, sessionModel: sessionModel)
                                                    .padding(.horizontal, appModel.layout.contentMinPadding)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: appModel.layout.adaptiveWidth(geometry))
                                }
                            }
                            .frame(maxWidth: geometry.size.width)
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            
        }
        // functions when UI of app changes
        .onAppear {
            BravoTextBubbleDelay()
        }
        .onDisappear {
            sessionModel.saveChanges()
        }
        .onChange(of: UIApplication.shared.applicationState) {
            if UIApplication.shared.applicationState == .background {
                sessionModel.saveChanges()
            }
        }
    }
    
    func BravoTextBubbleDelay() {
        // Initially hide the bubble
        appModel.viewState.showPreSessionTextBubble = false
        
        // Show it after a 1 second delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.3)) {
                appModel.viewState.showPreSessionTextBubble = true
            }
        }
    }

    // MARK: Bravo's message bubble
    private var preSessionMessageBubble: some View {
        ZStack(alignment: .center) {
            HStack(spacing: 0) {
                // Left Pointer
                Path { path in
                    path.move(to: CGPoint(x: 15, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 10))
                    path.addLine(to: CGPoint(x: 15, y: 20))
                }
                .fill(Color(hex:"E4FBFF"))
                .frame(width: 9, height: 20)
                .offset(y: 1)  // Adjust this to align with text
                
                // Text Bubble
                Text(sessionModel.orderedSessionDrills.isEmpty ? "Choose your skill to improve today" : "Looks like you got \(sessionModel.orderedSessionDrills.count) drills for today!")
                    .font(.custom("Poppins-Bold", size: 12))
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex:"E4FBFF"))
                    )
                    .frame(maxWidth: 150)
 
            }
            .offset(y: -15)
            .transition(.opacity.combined(with: .offset(y: 10)))
        }
    }
     
    // MARK: Filter Scroll View
    private var filterScrollView: some View {
        ZStack(alignment: .leading) {
            
            // Gray line below filters
            Rectangle()
                .stroke(appModel.globalSettings.primaryGrayColor.opacity(0.3), lineWidth: 1)
                .frame(height: 1)
                .offset(y: 30)
            
            // All filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
         
                    ForEach(FilterType.allCases, id: \.self) { type in
                        FilterButton(
                            appModel: appModel,
                            type: type,
                            icon: appModel.icon(for: type),
                            isSelected: appModel.selectedFilter == type,
                            value: sessionModel.filterValue(for: type)
                        ) {
                            if appModel.selectedFilter == type {
                                appModel.selectedFilter = nil
                            } else {
                                appModel.selectedFilter = type
                            }
                        }
                        .padding(.vertical, 3)
                    }
                }
                .frame(height: 50)
            }
            .padding(.leading, 70)
            
            // White filter button on the left
            FilterOptionsButton(appModel: appModel, sessionModel: sessionModel)
             
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 5)
    }
    
    // MARK: Save filters prompt
    private var saveFiltersPrompt: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    appModel.viewState.showSaveFiltersPrompt = false
                }
            
            VStack {
                HStack {
                    // Exit the prompt
                    Button(action: {
                        withAnimation {
                            appModel.viewState.showSaveFiltersPrompt = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Spacer()
                    
                    Text("Save filter")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                TextField("Name", text: $savedFiltersName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                // Save filters button
                Button(action: {
                    withAnimation {
                        sessionModel.saveFiltersInGroup(name: savedFiltersName)
                        appModel.viewState.showSaveFiltersPrompt = false
                    }
                }) {
                    Text("Save")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(appModel.globalSettings.primaryYellowColor)
                        .cornerRadius(8)
                }
                .disabled(savedFiltersName.isEmpty)
                .padding(.top, 16)
            }
            .padding()
            .frame(width: 300, height: 170)
            .background(Color.white)
            .cornerRadius(15)
        }
        .onDisappear {
            savedFiltersName = ""
        }
    }
    
    // MARK: Golden Button
    private var goldenButton: some View {
        Button(action: {
            withAnimation(.spring(dampingFraction: 0.7)) {
                appModel.viewState.showHomePage = false
                appModel.viewState.showPreSessionTextBubble = false
                
            }
            
            // Delay the appearance of field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.spring(dampingFraction: 0.7)) {
                    appModel.viewState.showFieldBehindHomePage = true
                }
            }
            
        }) {
            ZStack {
                RiveViewModel(fileName: "Golden_Button").view()
                    .frame(width: 320, height: 80)
                
                Text("Start Session")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .padding(.bottom, 10)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 80)
        .transition(.move(edge: .bottom))
    }
    
    private func sessionReady() -> Bool {
        !sessionModel.orderedSessionDrills.isEmpty && !appModel.viewState.showSkillSearch && appModel.viewState.showHomePage
    }
}
