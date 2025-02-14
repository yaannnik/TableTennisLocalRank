//
//  Utils.swift
//  TableTennisLocalRank
//
//  Created by 杨挹 on 2/13/25.
//

import Foundation

var currentDate: String {
    let today = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: today)
}
