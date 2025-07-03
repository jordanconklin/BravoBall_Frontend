// Update the ViewState struct to include properties for the initial session message
struct ViewState: Codable {
    var showingDrills = false
    var showFilter: Bool = true
    var showHomePage: Bool = true
    var showTextBubble: Bool = true
    var showSmallDrillCards: Bool = false
    var showFilterOptions: Bool = false
    var showSavedPrereqs: Bool = false
    var showSavedPrereqsPrompt: Bool = false
    var showSearchDrills: Bool = false
    var showDeleteButtons: Bool = false
    var showingDrillDetail: Bool = false
    var showSkillSearch: Bool = false
    
    // New properties for initial session message
    var showInitialSessionMessage: Bool = false
    var initialSessionMessageShown: Bool = false
} 