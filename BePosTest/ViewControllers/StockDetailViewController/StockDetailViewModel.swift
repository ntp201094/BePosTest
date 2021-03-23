//
//  StockDetailViewModel.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 19/03/2021.
//

import Foundation
import RxSwift
import RxCocoa

enum StockDetailViewModel: ViewModelType {
    struct Inputs {
        let selectOption: Observable<PeriodOption>
    }
    
    struct Outputs {
        let image: Observable<URL?>
        let changes: Observable<String>
        let changesColor: Observable<UIColor>
        let symbol: Observable<String>
        let name: Observable<String>
        let price: Observable<Double>
        let lastDiv: Observable<String>
        let sector: Observable<String>
        let industry: Observable<String>
        let histories: Observable<[HistoricalPrice]>
    }
    
    enum Action {
    }
    
    static func viewModel(symbol: String, name: String, profileObservable: Observable<StockDetail>, priceUpdateObservable: Observable<Double>) -> (Inputs) -> (Outputs, Driver<Action>) {
        return { inputs in
            
            let imageOutput = profileObservable.map { URL(string: $0.image) }
            let changesOutput = profileObservable.map { "\($0.changes)" }
            let changesColorOutput = profileObservable.map { $0.changes > 0 ? UIColor.green : UIColor.red }
            let symbolOutput = Observable.just(symbol)
            let nameOutput = Observable.just(name)
            let priceOutput = priceUpdateObservable
            let lastDivOuput = profileObservable.map { "\($0.lastDiv)" }
            let sectorOutput = profileObservable.map { $0.sector }
            let industry = profileObservable.map { $0.industry }
            
            let histories = inputs.selectOption
                .startWith(.quarter)
                .map({
                    switch $0 {
                    case .quarter:
                        return Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
                    case .yearHalf:
                        return Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
                    case .year:
                        return Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
                    case .tripleYears:
                        return Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date()
                    }
                })
                .flatMapLatest({
                    URLSession.shared.rx.dataTask(with: Requests.histories(symbol: symbol, from: $0, to: Date()).urlRequest)
                })
                .compactMap { $0.success }
                .map({
                    try! JSONDecoder().decode(HistoricalPriceList.self, from: $0).historical
                })
            
            return (
                Outputs(
                    image: imageOutput,
                    changes: changesOutput,
                    changesColor: changesColorOutput,
                    symbol: symbolOutput,
                    name: nameOutput,
                    price: priceOutput,
                    lastDiv: lastDivOuput,
                    sector: sectorOutput,
                    industry: industry,
                    histories: histories
                ),
                Driver.merge()
            )
        }
    }
}
