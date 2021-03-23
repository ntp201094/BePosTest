//
//  Configuration.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 18/03/2021.
//

import Foundation

struct Configuration {
    static let baseURLString = "https://financialmodelingprep.com"
    static let apiKey = "2cb24259570a3e688619bc6c61c68c3d"
    static let numberOfStocksOnScreen = 50
    static let priceUpdatingInterval = 15
}

enum PeriodOption: Int, CaseIterable {
    case quarter
    case yearHalf
    case year
    case tripleYears
    
    var name: String {
        switch self {
        case .quarter:
            return "3 months"
        case .yearHalf:
            return "6 months"
        case .year:
            return "1 year"
        case .tripleYears:
            return "3 years"
        }
    }
}
