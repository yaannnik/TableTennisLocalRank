//
//  Player.swift
//  TableTennisLocalRank
//
//  Created by 杨挹 on 2/11/25.
//

import Foundation

struct Player: Identifiable, Decodable, Encodable {
    var id: String
    var score: Int

    // Optional: Add a custom initializer to make decoding easier
    init(id: String, score: Int) {
        self.id = id
        self.score = score
    }
}
