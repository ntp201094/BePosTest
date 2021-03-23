//
//  StockDetail.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 23/03/2021.
//

import Foundation

struct StockDetail: Decodable {
    let changes: Double
    let image: String
    let lastDiv: Double
    let sector: String
    let industry: String
}
