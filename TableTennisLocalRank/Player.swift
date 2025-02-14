//
//  Player.swift
//  TableTennisLocalRank
//
//  Created by 杨挹 on 2/11/25.
//

import Foundation

struct Player: Identifiable, Decodable, Encodable, Hashable {
    var id: String
    var score: Int

    // Optional: Add a custom initializer to make decoding easier
    init(id: String, score: Int) {
        self.id = id
        self.score = score
    }
    
    mutating func updateScore(delta: Int) -> Void {
        self.score += delta
    }
}
