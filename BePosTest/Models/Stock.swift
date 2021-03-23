//
//  Stock.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 18/03/2021.
//

import Foundation

struct Stock: Decodable {
    let symbol: String
    let name: String
    let price: Double
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case name
        case price
    }
}

extension Stock {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.symbol = try values.decode(String.self, forKey: .symbol)
        self.name = (try? values.decode(String.self, forKey: .name)) ?? ""
        self.price = try values.decode(Double.self, forKey: .price)
    }
}
