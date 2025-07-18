//
//  DrillSearchView.swift
//  BravoBall
//
//  Created by Jordan on 3/17/25.
//


import SwiftUI

// Reusable drill search view that can be used in different contexts
struct DrillSearchView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Environment(\.viewGeometry) var geometry
    let globalSettings = GlobalSettings.shared
    
    // Callback for when drills are selected
    var onDrillsSelected: ([DrillModel]) -> Void
    // Title for the view
    var title: String
    // Text for the action button
    var actionButtonText: (Int) -> String
    // Optional filter function to exclude certain drills
    var filterDrills: ((DrillModel) -> Bool)?
    // Optional closure to check if a drill is already selected
    var isDrillSelected: ((DrillModel) -> Bool)?
    
    @Environment(\.dismiss) private var dismiss
    
    // Local state
    @State private var selectedDrill: DrillModel? = nil
    @State private var searchText: String = ""
    @State private var selectedDrills: [DrillModel] = []
    @State private var searchResults: [DrillModel] = []
    @State private var isLoading: Bool = false
    @State private var currentPage: Int = 1
    @State private var totalPages: Int = 1
    @State private var errorMessage: String? = nil
    @FocusState private var isFocused: Bool
    
    // Optional filters
    @State private var selectedCategory: String? = nil
    @State private var selectedDifficulty: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Header with title and dismiss button
                    HStack {
                        Spacer()
                        Text(title)
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .font(.custom("Poppins-Bold", size: 16))
                            .padding(.leading, 70)
                        Spacer()
                        Button("Done") {
                            Haptic.light()
                            dismiss()
                        }
                        .padding()
                        .foregroundColor(Color.blue)
                        .font(.custom("Poppins-Bold", size: 16))
                    }
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search drills...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .focused($isFocused)
                            .tint(globalSettings.primaryYellowColor)
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                Haptic.light()
                                searchText = ""
                                performSearch()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isFocused ? globalSettings.primaryYellowColor : globalSettings.primaryLightGrayColor, lineWidth: 3)
                    )
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Filter options
                    HStack(spacing: 12) {
                        // Category filter (simplified for now)
                        Menu {
                            Button("All Categories", action: { 
                                Haptic.light()
                                selectedCategory = nil })
                            Button("Dribbling", action: { 
                                Haptic.light()
                                selectedCategory = "dribbling" })
                            Button("Passing", action: { 
                                Haptic.light()
                                selectedCategory = "passing" })
                            Button("Shooting", action: { 
                                Haptic.light()
                                selectedCategory = "shooting" })
                            Button("First touch", action: { 
                                Haptic.light()
                                selectedCategory = "first_touch" })
                        } label: {
                            HStack {
                                Text(selectedCategory?.capitalized ?? "Category")
                                    .font(.custom("Poppins-Medium", size: 12))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Difficulty filter
                        Menu {
                            Button("All Difficulties", action: { 
                                Haptic.light()
                                selectedDifficulty = nil })
                            Button("Beginner", action: { 
                                Haptic.light()
                                selectedDifficulty = "beginner" })
                            Button("Intermediate", action: { 
                                Haptic.light()
                                selectedDifficulty = "intermediate" })
                            Button("Advanced", action: { 
                                Haptic.light()
                                selectedDifficulty = "advanced" })
                        } label: {
                            HStack {
                                Text(selectedDifficulty?.capitalized ?? "Difficulty")
                                    .font(.custom("Poppins-Medium", size: 12))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        // Search button
                        Button(action: {
                            Haptic.light()
                            performSearch()
                        }) {
                            Text(searchText.isEmpty && selectedCategory == nil && selectedDifficulty == nil ? "Show All" : "Search")
                                .font(.custom("Poppins-Bold", size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(globalSettings.primaryYellowColor)
                                .cornerRadius(8)
                        }
                        
                        // Clear filters button (only shown when filters are active)
                        if !searchText.isEmpty || selectedCategory != nil || selectedDifficulty != nil {
                            Button(action: {
                                Haptic.light()
                                searchText = ""
                                selectedCategory = nil
                                selectedDifficulty = nil
                                performSearch()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Clear")
                                }
                                .font(.custom("Poppins-Bold", size: 12))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Error message if present
                    if let errorMessage = errorMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 32))
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                    
                    // Loading indicator
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .tint(globalSettings.primaryYellowColor)
                            
                            Text("Loading drills...")
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if searchResults.isEmpty {
                        // Empty state
                        VStack {
                            Spacer()
                            if errorMessage == nil {
                                // No results for search
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass.circle")
                                        .font(.system(size: 32))
                                        .foregroundColor(.orange)
                                    
                                    Text(errorMessage ?? "No drills found matching your criteria")
                                        .font(.custom("Poppins-Medium", size: 16))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    Text("Try removing some filters or using different search terms")
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(.gray.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    Button(action: {
                                        Haptic.light()
                                        searchText = ""
                                        selectedCategory = nil
                                        selectedDifficulty = nil
                                        performSearch()
                                    }) {
                                        Text("Show all drills")
                                            .font(.custom("Poppins-Medium", size: 14))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(globalSettings.primaryYellowColor)
                                            .cornerRadius(8)
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            Spacer()
                        }
                    } else {
                        // Results list
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(searchResults) { drill in
                                    DrillRowForSearch(
                                        appModel: appModel,
                                        sessionModel: sessionModel,
                                        drill: drill,
                                        isSelected: selectedDrills.contains(drill),
                                        isAlreadyInSession:  sessionModel.orderedSessionDrills.contains(where: { $0.drill.title == drill.title }),
                                        onSelect: { toggleDrillSelection(drill) }
                                    )
                                    .onTapGesture {
                                        selectedDrill = drill
                                    }
                                    .padding(.horizontal)
                                    
                                    Divider()
                                }
                            }
                            
                            // Pagination controls
                            if totalPages > 1 {
                                HStack {
                                    if currentPage > 1 {
                                        Button(action: { 
                                            Haptic.light()
                                            loadPreviousPage() 
                                        }) {
                                            Image(systemName: "chevron.left")
                                                .foregroundColor(globalSettings.primaryDarkColor)
                                        }
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    
                                    Text("Page \(currentPage) of \(totalPages)")
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(.gray)
                                    
                                    if currentPage < totalPages {
                                        Button(action: { 
                                            Haptic.light()
                                            loadNextPage() 
                                        }) {
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(globalSettings.primaryDarkColor)
                                        }
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    
                    // Add button
                    if !selectedDrills.isEmpty {
                        
                        PrimaryButton(
                            title: actionButtonText(selectedDrills.count),
                            action: {
                                // Call the callback with the selected drills
                                Haptic.light()
                                onDrillsSelected(selectedDrills)
                                
                                // Clear selection
                                selectedDrills = []
                            },
                            frontColor: globalSettings.primaryYellowColor,
                            backColor: globalSettings.primaryDarkYellowColor,
                            textColor: Color.white,
                            textSize: 18,
                            width: .infinity,
                            height: 50,
                            disabled: false
                                
                        )
                        .padding()
                        
                        
                    }
                }
                .frame(width: geometry.size.width)
                .onAppear {
                    // Directly call performSearch without any filters
                    // to load all drills immediately
                    searchText = ""
                    selectedCategory = nil
                    selectedDifficulty = nil
                    currentPage = 1
                    performSearch()
                }
                .onChange(of: selectedCategory) {
                    // Reset page and perform search when category changes
                    currentPage = 1
                    performSearch()
                }
                .onChange(of: selectedDifficulty) {
                    // Reset page and perform search when difficulty changes
                    currentPage = 1
                    performSearch()
                }

            }
            .navigationDestination(item: $selectedDrill) { drill in
                DrillDetailView(appModel: appModel, sessionModel: sessionModel, drill: drill)
            }

        }
    }
    
    // MARK: - Helper Methods
    
    // Toggle drill selection
    func toggleDrillSelection(_ drill: DrillModel) {
        // Check if the drill is already in the target group
        if let isDrillAlreadySelected = isDrillSelected?(drill), isDrillAlreadySelected {
            // Don't allow selecting drills that are already in the group
            print("⚠️ Drill is already in the group: '\(drill.title)'")
            return
        }
        
        if selectedDrills.contains(drill) {
            selectedDrills.removeAll(where: { $0.id == drill.id })
        } else {
            // Check if a drill with the same title is already selected
            if let existingIndex = selectedDrills.firstIndex(where: { $0.title == drill.title }) {
                print("⚠️ Drill with same title already selected: '\(drill.title)' with index \(existingIndex)")
                // Don't add another one
            } else {
                selectedDrills.append(drill)
            }
        }
    }
    
    // Perform search with current filters
    func performSearch() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await DrillSearchService.shared.searchDrills(
                    query: searchText,
                    category: selectedCategory,
                    difficulty: selectedDifficulty,
                    page: currentPage,
                    limit: 50  // Increase limit to show more results
                )
                
                // Convert API response to local models
                let drills = DrillSearchService.shared.convertToLocalModels(drillResponses: response.items)
                
                // Update UI on main thread
                await MainActor.run {
                    searchResults = drills
                    totalPages = response.totalPages
                    isLoading = false
                    
                    // Only show error message if we have an actual search query and no results
                    if drills.isEmpty && (!searchText.isEmpty || selectedCategory != nil || selectedDifficulty != nil) {
                        // Construct a more specific message based on what was searched for
                        var errorDetails = "No drills found"
                        
                        if !searchText.isEmpty {
                            errorDetails += " matching '\(searchText)'"
                        }
                        
                        if let category = selectedCategory {
                            errorDetails += " in the '\(category.capitalized)' category"
                        }
                        
                        if let difficulty = selectedDifficulty {
                            errorDetails += " with '\(difficulty.capitalized)' difficulty"
                        }
                        
                        errorMessage = errorDetails
                    } else {
                        errorMessage = nil
                    }
                }
            } catch {
                await MainActor.run {
                    searchResults = []
                    isLoading = false
                    
                    // Don't show error on initial empty state
                    if searchText.isEmpty && selectedCategory == nil && selectedDifficulty == nil {
                        errorMessage = nil
                    } else {
                        errorMessage = "Failed to load drills: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // Load previous page of results
    func loadPreviousPage() {
        if currentPage > 1 {
            currentPage -= 1
            performSearch()
        }
    }
    
    // Load next page of results
    func loadNextPage() {
        if currentPage < totalPages {
            currentPage += 1
            performSearch()
        }
    }
}

// Drill row component specifically for search results
struct DrillRowForSearch: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let drill: DrillModel
    let isSelected: Bool
    let isAlreadyInSession: Bool
    let onSelect: () -> Void
    
    private let layout = ResponsiveLayout.shared
    
    
    var body: some View {
        HStack {
            Image(sessionModel.skillIconName(for: drill.skill))
                .resizable()
                .scaledToFit()
                .frame(width: layout.isPad ? 44 : 40, height: layout.isPad ? 44 : 40)
                .padding(6)
            
            VStack(alignment: .leading) {
                Text(drill.title)
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(.black)
                
                HStack(spacing: 8) {
                    // Display category/skill as a pill
                    Text(drill.skill)
                        .font(.custom("Poppins-Regular", size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(colorForSkill(drill.skill))
                        .cornerRadius(12)
                    
                    // Display difficulty as a pill
                    Text(drill.difficulty)
                        .font(.custom("Poppins-Regular", size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(colorForDifficulty(drill.difficulty))
                        .cornerRadius(12)
                }
                
                Text(drill.description)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if isAlreadyInSession {
                Text("Already added")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.gray)
            } else {
                Button(action: onSelect) {
                    Checkbox(appModel: appModel, isSelected: isSelected)
                }
            }
        }
        .padding(.vertical, 8)
        .opacity(isAlreadyInSession ? 0.6 : 1.0)
    }
    
    // Helper methods for coloring
    func colorForSkill(_ skill: String) -> Color {
        switch skill.lowercased() {
        case "dribbling":
            return Color.blue
        case "passing":
            return Color.green
        case "shooting":
            return Color.orange
        case "defending":
            return Color.red
        default:
            return Color.purple
        }
    }
    
    func colorForDifficulty(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner":
            return Color.green
        case "intermediate":
            return Color.orange
        case "advanced":
            return Color.red
        default:
            return Color.gray
        }
    }
}
