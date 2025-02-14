//
//  Game.swift
//  TableTennisLocalRank
//
//  Created by 杨挹 on 2/13/25.
//

import Foundation

struct Game {
    var homePlayer: Player
    var awayPlayer: Player
    var homeScore: Int
    var awayScore: Int
    var winner: Player? {
        if !validateFinalScore() {
            print("Not a valid final score")
            return nil
        }
        if homeScore > awayScore {
            return homePlayer
        } else if awayScore > homeScore {
            return awayPlayer
        } else {
            return nil  // No winner if it's a tie
        }
    }
    var loser: Player? {
        if !validateFinalScore() {
            print("Not a valid final score")
            return nil
        }
        if homeScore > awayScore {
            return awayPlayer
        } else if awayScore > homeScore {
            return homePlayer
        } else {
            return nil  // No winner if it's a tie
        }
    }
    
    init(hPlayer: Player, aPlayer: Player, hScore: Int, aScore: Int) {
        self.homePlayer = hPlayer
        self.awayPlayer = aPlayer
        self.homeScore = hScore
        self.awayScore = aScore
    }
    
    func validateFinalScore() -> Bool {
        // Case 1: A player reaches exactly 11 while the opponent is at most 9
        if (homeScore == 11 && awayScore <= 9) || (awayScore == 11 && homeScore <= 9) {
            return true
        }
        
        // Case 2: Both scores exceed 11, and one player leads by at least 2 points
        if homeScore >= 10 || awayScore >= 10 {
            return abs(homeScore - awayScore) == 2
        }
        
        return false
    }
    
    func delta() -> Int {
        return abs(homeScore - awayScore)
    }
}
