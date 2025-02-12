//
//  NewSessionView.swift
//  TableTennisLocalRank
//
//  Created by 杨挹 on 2/11/25.
//

import SwiftUI

struct NewSessionView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showAddPlayerSheet = false
    @State private var playerID = ""
    @State private var initialScore = ""
    @State private var showDuplicateIdAlert = false
    @State private var showInvalidScoreAlert = false
    @State private var playerList: [Player] = []  // Change from [(String, String)] to [Player]
    
    init() {
        // Load player list from UserDefaults when the view is created
        if let savedPlayers = UserDefaults.standard.data(forKey: "playerList") {
            let decoder = JSONDecoder()
            if let loadedPlayers = try? decoder.decode([Player].self, from: savedPlayers) {
                _playerList = State(initialValue: loadedPlayers)
            }
        }
    }
    
    func savePlayerList() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(playerList) {
            UserDefaults.standard.set(encoded, forKey: "playerList")
        }
    }
    
    func loadPlayerList() {
        if let savedPlayers = UserDefaults.standard.data(forKey: "playerList") {
            let decoder = JSONDecoder()
            if let loadedPlayers = try? decoder.decode([Player].self, from: savedPlayers) {
                playerList = loadedPlayers
            }
        }
    }
    
    private func deletePlayer(at offsets: IndexSet) {
        playerList.remove(atOffsets: offsets)  // Remove player from the list at the given index
        savePlayerList()
    }
    
    var currentDate: String {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: today)
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                Text("New Session\n\(currentDate)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding()
                
                List {
                    ForEach(playerList, id: \.id) { player in
                        HStack {
                            Text(player.id)
                                .fontWeight(.bold)
                            Spacer()
                            Text(player.score)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .onDelete(perform: deletePlayer) // Swipe-to-delete action
                }
                .padding(.top)
                .frame(maxHeight: 300) // Limit the list height if necessary
                
                HStack(spacing: 20) {
                    Button(action: {
                        // show add player Popup
                        showAddPlayerSheet.toggle()
                    }) {
                        Text("Add Player")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        print("Continue clicked")
                    }) {
                        Text("Continue")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            
            // Add Player Popup
            .sheet(isPresented: $showAddPlayerSheet) {
                VStack {
                    Text("Add Player")
                        .font(.title)
                        .padding()
                    
                    // playerID
                    TextField("Enter Player ID", text: $playerID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    // initialScore
                    TextField("Enter Initial Score", text: $initialScore)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .keyboardType(.numberPad)
                    
                    HStack {
                        Button(action: {
                            if let score = Int(initialScore), !playerID.isEmpty {
                                // Prevent duplicates by checking if playerID already exists in playerList
                                if !playerList.contains(where: { $0.id == playerID }) {
                                    playerList.append(Player(id:playerID, score:String(score)))  // Add player to the list
                                    playerID = ""  // Clear the playerID input field
                                    initialScore = ""  // Clear the initialScore input field
                                    
                                    savePlayerList()
                                    
                                    showAddPlayerSheet.toggle()  // Dismiss the sheet
                                } else {
                                    // Show an alert or feedback that the player already exists
                                    print("Player ID already exists!")
                                    showDuplicateIdAlert = true
                                }
                            } else {
                                // Handle the case where the score is invalid
                                print("Invalid score!")
                                showInvalidScoreAlert = true  // Set a flag to show the alert for invalid score
                            }
                        }) {
                            Text("Confirm")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // close popup
                            showAddPlayerSheet.toggle()
                        }) {
                            Text("Cancel")
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .alert(isPresented: $showDuplicateIdAlert) {
                Alert(
                    title: Text("Duplicate Player ID"),
                    message: Text("The player ID \(playerID) already exists in the list."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showInvalidScoreAlert) {
                Alert(title: Text("Invalid Score"), message: Text("Please enter a valid integer for the score."), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            loadPlayerList()  // Load player list every time the view appears
        }
    }
}

#Preview {
    NewSessionView()
}

