//
//  HistoricalPrice.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 22/03/2021.
//

import Foundation

struct HistoricalPriceList: Decodable {
    let symbol: String
    let historical: [HistoricalPrice]
}

struct HistoricalPrice: Decodable {
    let date: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    let change: Double
}
