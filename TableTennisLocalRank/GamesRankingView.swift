//
//  GamesRankingView.swift
//  TableTennisLocalRank
//
//  Created by 杨挹 on 2/13/25.
//

import SwiftUI

struct GamesRankingView: View {
    enum AlertType {
        case samePlayer // Player ID as associated value
        case invalidScore
        case invalidFinalScore
    }
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showAddGameSheet: Bool = false
    @State private var playerList: [Player] = []  // Change from [(String, String)] to [Player]
    @State private var homePlayer: Player?
    @State private var awayPlayer: Player?
    @State private var homeScore = ""
    @State private var awayScore = ""
    @State private var activeAlert: AlertType?
    @State private var addingGameAlert = false
    
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
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                Text("World Ranking\n\(currentDate)")
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
                    // .onDelete(perform: deletePlayer)
                    // Delete is not allowed on this page
                }
                .padding(.top)
                .frame(maxHeight: 500) // Limit the list height if necessary
                
                HStack(alignment: .center, spacing: 20.0) {
                    Button(action: {
                        // show add game Popup
                        showAddGameSheet.toggle()
                    }) {
                        Text("Add Game")
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            
            .sheet(isPresented: $showAddGameSheet) {
                VStack {
                    Text("Add Game")
                        .font(.title)
                        .padding()
                    
                    HStack {
                        Picker("Select a Player", selection: $homePlayer) {
                            ForEach(playerList, id: \.id) { player in
                                Text(player.id).tag(player as Player?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        
                        Picker("Select a Player", selection: $awayPlayer) {
                            ForEach(playerList, id: \.id) { player in
                                Text(player.id).tag(player as Player?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                    }
                    
                    HStack {
                        TextField("Enter Home Player Score", text: $homeScore)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .keyboardType(.numberPad)
                        
                        // initialScore
                        TextField("Enter Away Player Score", text: $awayScore)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Button(action: {
                            print("Confirm")
                            if let hScore = Int(homeScore), let aScore = Int(awayScore), hScore >= 0, aScore >= 0 {
                                if homePlayer == awayPlayer || homePlayer == nil || awayPlayer == nil {
                                    print("Adding same player")
                                    addingGameAlert = true
                                    activeAlert = .samePlayer
                                } else {
                                    let game = Game(hPlayer: homePlayer!, aPlayer: awayPlayer!, hScore: hScore, aScore: aScore)
                                    if !game.validateFinalScore() {
                                        print("Invalid final score")
                                        addingGameAlert = true
                                        activeAlert = .invalidFinalScore
                                    } else {
                                        let deltaScore = game.delta() - 1
                                        let winner: Player? = game.winner
                                        let loser: Player? = game.loser
                                        for i in playerList.indices {
                                            if playerList[i] == winner! {
                                                playerList[i].updateScore(delta: 40 + deltaScore)
                                            } else if playerList[i] == loser! {
                                                playerList[i].updateScore(delta: -10 - deltaScore)
                                            }
                                        }
                                        homeScore = ""
                                        awayScore = ""
                                        homePlayer = nil
                                        awayPlayer = nil
                                        savePlayerList()
                                        showAddGameSheet.toggle()
                                    }
                                }
                            } else {
                                print("Invalid score")
                                addingGameAlert = true
                                activeAlert = .invalidScore
                            }
                        }) {
                            Text("Confirm")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .alert(isPresented: $addingGameAlert) {
                            switch activeAlert {
                            case .samePlayer:
                                return Alert(
                                    title: Text("Same Player"),
                                    message: Text("Same player selected twice."),
                                    dismissButton: .default(Text("OK"))
                                )
                            case .invalidScore:
                                return Alert(
                                    title: Text("Invalid Score"),
                                    message: Text("Please enter a valid score."),
                                    dismissButton: .default(Text("OK"))
                                )
                            case .invalidFinalScore:
                                return Alert(
                                    title: Text("Invalid Final Score"),
                                    message: Text("This is not a finished game."),
                                    dismissButton: .default(Text("OK"))
                                )
                            case .none:
                                return Alert(title: Text("Unknown Error")) // Fallback case (shouldn't occur)
                            }
                        }
                        
                        
                        Button(action: {
                            // close popup
                            showAddGameSheet.toggle()
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
    }
}

// A SwiftUI preview.
#Preview {
    GamesRankingView()
}
