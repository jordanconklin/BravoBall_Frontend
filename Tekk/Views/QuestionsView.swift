//
//  QuestionsView.swift
//  Tekk
//
//  Created by Joshua Conklin on 10/7/24.
//
import SwiftUI
import RiveRuntime


// MARK: - welcomeQs
struct welcomeQs: View {
    @StateObject private var globalSettings = GlobalSettings()

    @Binding var welcomeInput: Int
    @Binding var firstName: String
    @Binding var lastName: String
    
    //  options for lists
    let ageOptions = Array (5...100).map { String($0) }
    let levelOptions = ["Beginner", "Intermediate", "Competitive", "Professional"]
    let positionOptions = ["Goalkeeper", "Fullback", "Centerback", "Defensive Mid", "Central Mid", "Attacking Mid", "Winger", "Forward"]
    
    @Binding var selectedAge: String
    @Binding var selectedLevel: String
    @Binding var selectedPosition: String
    
    @State private var isEditingFirstName = false
    @State private var isEditingLastName = false
    
    var body: some View {
        VStack(spacing: 25) {
            // first name, Zstack so placeholder is on top of input text
            ZStack(alignment: .leading) {
                if firstName.isEmpty {
                    Text("First Name")
                        .foregroundColor(.gray)
                        .padding(.leading, 16)
                        .font(.custom("Poppins-Bold", size: 16))
                }
                TextField("", text: $firstName)
                .padding()
                .foregroundColor(globalSettings.primaryDarkColor)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .font(.custom("Poppins-Bold", size: 16))
            }
            .frame(height: 60)
            
            // last name, Zstack so placeholder is on top of input text
            ZStack(alignment: .leading) {
                if lastName.isEmpty {
                    Text("Last Name")
                        .foregroundColor(.gray)
                        .padding(.leading, 16)
                        .font(.custom("Poppins-Bold", size: 16))
                }
                TextField("", text: $lastName)
                .padding()
                .foregroundColor(globalSettings.primaryDarkColor)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .font(.custom("Poppins-Bold", size: 16))
            }
            .frame(height: 60)
            
            // confined version of structure drop down menus
            dropDownMenu(title: $selectedAge, options: ageOptions, placeholder: "Select your Age")
            dropDownMenu(title: $selectedLevel, options: levelOptions, placeholder: "Select your Level")
            dropDownMenu(title: $selectedPosition, options: positionOptions, placeholder: "Select your Position")
                .frame(height: 60)
                .padding(.bottom, 325)
                .transition(.move(edge: .bottom))
        }
        .padding(.horizontal)
        .padding(.top, 500)
    }
}


// MARK: - Drop Down Menu (for Q1)
struct dropDownMenu: View {
    @StateObject private var globalSettings = GlobalSettings()

    @Binding var title: String
    var options: [String]
    var placeholder: String
    @State private var showList: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation {
                    showList.toggle()
                }
            }) {
                HStack {
                    Text(title.isEmpty ? placeholder : title)
                        .foregroundColor(title.isEmpty ? .gray : globalSettings.primaryDarkColor)
                        .padding(.leading, 16)
                        .font(.custom("Poppins-Bold", size: 16))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .padding(.trailing, 16)
                        .foregroundColor(globalSettings.primaryDarkColor)
                }
                .frame(height: 60)
                .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1))
            }
            
            if showList {
                VStack {
                    ScrollView {
                        // lazy for better performance
                        LazyVStack {
                            ForEach(options, id: \.self) { option in
                                Button(action: {
                                    title = option
                                    showList = false
                                }) {
                                    //edit inside drop down element
                                    Text(option)
                                        .padding()
                                        .foregroundColor(globalSettings.primaryDarkColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.custom("Poppins-Bold", size: 16))
                                }
                                // edit full drop down menu appearance
                                .background(.white)
                                .cornerRadius(5)
                            }
                        }
                    }
                    .frame(height: 180) // Set height limit for the ScrollView
                }
                .background(.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding(.horizontal)
            }
        }
    }
}



// MARK: - Questionnaire 1
struct Questionnaire_1: View {
    @StateObject private var globalSettings = GlobalSettings()

    @Binding var currentQuestionnaire: Int
    @Binding var selectedPlayer: String
    @Binding var chosenPlayers: [String]
    
    //LazyVStack options for players
    let players = ["Alan Virginius", "Harry Maguire", "Big Bjorn", "Big Adam", "Big Bulk", "Oscar Bobb", "Gary Gardner", "The Enforcer"]
    
    var body: some View {
        VStack (spacing: 25) {
            // LazyVStack used for memory usage, since this will be a large list
            LazyVStack (spacing: 10) {
                ForEach(players, id: \.self) { player in
                    Button(action: {
                        togglePlayerSelection(player)
                    }) {
                        HStack {
                            Text(player)
                                .foregroundColor(globalSettings.primaryDarkColor)
                                .padding()
                                .font(.custom("Poppins-Bold", size: 16))
                            Spacer()
                            if chosenPlayers.contains(player) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(globalSettings.primaryDarkColor)
                            }
                        }
                        .background(chosenPlayers.contains(player) ? globalSettings.primaryYellowColor : Color.clear)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1) // Customize border color and width
                        )
                    }
                }
            }
            // LazyVStack padding
            .padding(.horizontal)
        }
        // VStack padding
        .padding(.horizontal)
    }
    
    private func togglePlayerSelection(_ player: String) {
        if chosenPlayers.contains(player) {
            // If the player is already selected, remove them. Prevents from multiple selections of one player
            chosenPlayers.removeAll { $0 == player }
        } else if chosenPlayers.count < 3 { // indices
            // If the player is not selected and we have less than 3, add them
            chosenPlayers.append(player)
        }
    }
}


// MARK: - Questionnaire 2
struct Questionnaire_2: View {
    @StateObject private var globalSettings = GlobalSettings()

    @Binding var currentQuestionnaire: Int
    @Binding var selectedStrength: String
    @Binding var chosenStrengths: [String] // Change to Binding
    
    //LazyVStack options for players
    let strengths = ["Passing", "Dribbling", "Shooting", "First Touch", "Crossing", "1v1 Defending", "1v1 Attacking", "Vision"]
    
    var body: some View {
        VStack (spacing: 25) {
            // LazyVStack used for memory usage, since this will be a large list
            LazyVStack (spacing: 10) {
                ForEach(strengths, id: \.self) { strength in
                    Button(action: {
                        toggleStrengthSelection(strength)
                    }) {
                        HStack {
                            Text(strength)
                                .foregroundColor(globalSettings.primaryDarkColor)
                                .padding()
                                .font(.custom("Poppins-Bold", size: 16))
                            Spacer()
                            if chosenStrengths.contains(strength) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(globalSettings.primaryDarkColor)
                            }
                        }
                        .background(chosenStrengths.contains(strength) ? globalSettings.primaryYellowColor : Color.clear)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1) // Customize border color and width
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    private func toggleStrengthSelection(_ strength: String) {
        if chosenStrengths.contains(strength) {
            // If the player is already selected, remove them. Prevents from multiple selections of one player
            chosenStrengths.removeAll { $0 == strength }
        } else if chosenStrengths.count < 3 { // count max = 2 because they're indices
            // If the player is not selected and we have less than 3, add them
            chosenStrengths.append(strength)
        }
    }
}


// MARK: - Questionnaire 3
struct Questionnaire_3: View {
    @StateObject private var globalSettings = GlobalSettings()

    @Binding var currentQuestionnaire: Int
    @Binding var selectedWeakness: String
    @Binding var chosenWeaknesses: [String] // Change to Binding
    
    //LazyVStack options for players
    let weaknesses = ["Passing", "Dribbling", "Shooting", "First Touch", "Crossing", "1v1 Defending", "1v1 Attacking", "Vision"]
    
    var body: some View {
        VStack (spacing: 25) {
            // LazyVStack used for memory usage, since this will be a large list
            LazyVStack (spacing: 10) {
                ForEach(weaknesses, id: \.self) { weakness in
                    Button(action: {
                        toggleWeaknessSelection(weakness)
                    }) {
                        HStack {
                            Text(weakness)
                                .foregroundColor(globalSettings.primaryDarkColor)
                                .padding()
                                .font(.custom("Poppins-Bold", size: 16))
                            Spacer()
                            if chosenWeaknesses.contains(weakness) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(globalSettings.primaryDarkColor)
                            }
                        }
                        .background(chosenWeaknesses.contains(weakness) ? globalSettings.primaryYellowColor : Color.clear)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1) // Customize border color and width
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    private func toggleWeaknessSelection(_ weakness: String) {
        if chosenWeaknesses.contains(weakness) {
            // If the player is already selected, remove them. Prevents from multiple selections of one player
            chosenWeaknesses.removeAll { $0 == weakness }
        } else if chosenWeaknesses.count < 3 { // count max = 2 because they're indices
            // If the player is not selected and we have less than 3, add them
            chosenWeaknesses.append(weakness)
        }
    }
}



