//
//  StockCellViewModel.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 19/03/2021.
//

import Foundation
import RxSwift
import RxCocoa

struct StockCellViewModel {
    let symbol: String
    let name: String
    let price: Double
    var isFavorite: Bool
    let intervalPriceUpdatingObservable: Observable<Void>
    let profileObservable: Observable<StockDetail>
}
