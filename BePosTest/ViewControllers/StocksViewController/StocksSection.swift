//
//  StocksSection.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 19/03/2021.
//

import Foundation
import RxDataSources

enum StocksSection {
    case stocks(items: [StocksSectionItem])
}

enum StocksSectionItem: IdentifiableType, Equatable {
    case loading
    case stock(viewModel: StockCellViewModel)
    
    var identity: String {
        switch self {
        case .loading:
            return "Loading_\(Int.random(in: 0..<99999))"
        case .stock(let viewModel):
            return "Stock_\(viewModel.symbol)_\(viewModel.price)_\(viewModel.isFavorite)"
        }
    }
    
    static func == (lhs: StocksSectionItem, rhs: StocksSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension StocksSection: AnimatableSectionModelType {
    var identity: String {
        switch self {
        case .stocks:
            return "Stocks"
        }
    }
    
    var items: [StocksSectionItem] {
        switch self {
        case .stocks(let items):
            return items
        }
    }
    
    init(original: StocksSection, items: [StocksSectionItem]) {
        switch original {
        case .stocks: self = .stocks(items: items)
        }
    }
}
