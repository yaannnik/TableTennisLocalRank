//
//  NewSessionView.swift
//  TableTennisLocalRank
//
//  Created by 杨挹 on 2/11/25.
//

import SwiftUI

struct NewSessionView: View {
    enum AlertType {
        case duplicatePlayer(String) // Player ID as associated value
        case invalidScore
    }
    
    @Environment(\.dismiss) var dismiss
    
    @State private var navigatingToGameView = false
    
    @State private var showAddPlayerSheet = false
    @State private var playerID = ""
    @State private var initialScore = ""
    @State private var activeAlert: AlertType? // Single alert state
    @State private var addingPlayerAlert = false       // Controls whether alert is shown
    @State private var playerNumberAlert = false
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
    
//    var currentDate: String {
//        let today = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        return dateFormatter.string(from: today)
//    }
    
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
                    // always show this sorted ranking
                    ForEach(playerList.sorted { $0.score > $1.score }, id: \.id) { player in
                        HStack {
                            Text(player.id)
                                .fontWeight(.bold)
                            Spacer()
                            Text(String(player.score))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .onDelete(perform: deletePlayer) // Swipe-to-delete action
                }
                .padding(.top)
                .frame(maxHeight: 600) // Limit the list height if necessary
                
                HStack(alignment: .center, spacing: 20.0) {
                    Button(action: {
                        // show add player Popup
                        showAddPlayerSheet.toggle()
                    }) {
                        Text("Add Player")
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        playerNumberAlert = playerList.count < 2
                        navigatingToGameView = !playerNumberAlert
                    }) {
                        Text("Go To Games")
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $playerNumberAlert) {
                        return Alert(
                            title: Text("Add more player"),
                            message: Text("At lease two players are needed"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    NavigationLink(
                        destination: GamesRankingView(),
                        isActive: $navigatingToGameView) {
                            EmptyView()
                        }
                }
                .frame(maxWidth: .infinity)
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
                            if let score = Int(initialScore), score >= 0, !playerID.isEmpty {
                                if !playerList.contains(where: { $0.id == playerID }) {
                                    playerList.append(Player(id: playerID, score: score))
                                    playerID = ""
                                    initialScore = ""
                                    savePlayerList()
                                    showAddPlayerSheet.toggle()
                                } else {
                                    activeAlert = .duplicatePlayer(playerID)
                                    addingPlayerAlert = true
                                }
                            } else {
                                activeAlert = .invalidScore
                                addingPlayerAlert = true
                            }
                        }) {
                            Text("Confirm")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .alert(isPresented: $addingPlayerAlert) {
                            switch activeAlert {
                            case .duplicatePlayer(let id):
                                return Alert(
                                    title: Text("Duplicate Player ID"),
                                    message: Text("Player \(id) already exists in the list."),
                                    dismissButton: .default(Text("OK"))
                                )
                            case .invalidScore:
                                return Alert(
                                    title: Text("Invalid Score"),
                                    message: Text("Please enter a valid id or starting score."),
                                    dismissButton: .default(Text("OK"))
                                )
                            case .none:
                                return Alert(title: Text("Unknown Error")) // Fallback case (shouldn't occur)
                            }
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
        }
        .onAppear {
            loadPlayerList()  // Load player list every time the view appears
        }
    }
}

#Preview {
    NewSessionView()
}

