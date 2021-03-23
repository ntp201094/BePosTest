//
//  StocksViewModel.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 17/03/2021.
//

import Foundation
import RxSwift
import RxCocoa

enum StocksViewModel: ViewModelType {
    struct Inputs {
        let select: Observable<StocksSectionItem>
        let favoriteItem: Observable<String>
        let unfavoriteItem: Observable<String>
        let favoriteListToggle: Observable<Void>
        let updatePrice: Observable<String>
        let showSettings: Observable<Void>
    }
    
    struct Outputs {
        let sections: Observable<[StocksSection]>
        let isFavoriteList: Observable<Bool>
    }
    
    enum Action {
        case stockDetail(symbol: String, name: String, profileObservable: Observable<StockDetail>, intervalPriceUpdateObservable: Observable<Double>)
        case settings
    }
    
    static func viewModel() -> (Inputs) -> (Outputs, Driver<Action>) {
        return { inputs in
            
            enum State {
                case loading
                case stocks(viewModels: [StockCellViewModel])
                case updateFavorite(symbol: String, isFavorite: Bool)
                case updatePrice(symbol: String, price: Double)
            }
            
            enum FavoriteListState {
                case favorite
                case unfavorite
            }
            
            let response = Observable.just(())
                .flatMapLatest({
                    URLSession.shared.rx.dataTask(with: Requests.stocks.urlRequest)
                })
                .share(replay: 1)
            
            let stocks = response
                .compactMap { $0.success }
                .map({ data -> [StockCellViewModel] in
                    try JSONDecoder().decode([Stock].self, from: data)
                        .prefix(Configuration.numberOfStocksOnScreen)
                        .map { stock -> StockCellViewModel in
                            let intervalObservable = Observable<Int>.interval(.seconds(Configuration.priceUpdatingInterval), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                                .asVoid()
                                .share()
                            let profileObservable = self.profileObservable(symbol: stock.symbol)
                            return StockCellViewModel(
                                symbol: stock.symbol,
                                name: stock.name,
                                price: stock.price,
                                isFavorite: false,
                                intervalPriceUpdatingObservable: intervalObservable,
                                profileObservable: profileObservable)
                        }
                })
                .share(replay: 1)
            
            let favoriteListToggled = inputs.favoriteListToggle
                .scan(false, accumulator: { current, _ in !current })
                .share(replay: 1)
            
            let updatePrice = inputs.updatePrice
                .flatMap({
                    URLSession.shared.rx.dataTask(with: Requests.currentPrice(symbol: $0).urlRequest)
                })
                .compactMap { $0.success }
                .map({
                    try JSONDecoder().decode([ShortQuote].self, from: $0).first!
                })
                .share(replay: 1)
            
            let sections = Observable.merge(
                Observable.just(State.loading),
                stocks.map { State.stocks(viewModels: $0) },
                inputs.favoriteItem.map { State.updateFavorite(symbol: $0, isFavorite: true) },
                inputs.unfavoriteItem.map { State.updateFavorite(symbol: $0, isFavorite: false) },
                updatePrice.map { State.updatePrice(symbol: $0.symbol, price: $0.price) }
            )
            .scan(into: [StocksSection](arrayLiteral: .stocks(items: [])), accumulator: { current, next in
                switch next {
                case .loading:
                    current[0] = .stocks(items: [StocksSectionItem](repeating: .loading, count: 10))
                case .stocks(let viewModels):
                    current[0] = StocksSection(original: current[0], items: viewModels.map { StocksSectionItem.stock(viewModel: $0) })
                case let .updateFavorite(symbol, isFavorite):
                    var items = current[0].items
                    var oldViewModel: StockCellViewModel!
                    guard let index = items
                            .firstIndex(where: { item -> Bool in
                                if case let .stock(viewModel) = item, viewModel.symbol == symbol {
                                    oldViewModel = viewModel
                                    return true
                                } else {
                                    return false
                                }
                            })
                    else { return }
                    let newViewModel = StockCellViewModel(
                        symbol: oldViewModel.symbol,
                        name: oldViewModel.name,
                        price: oldViewModel.price,
                        isFavorite: isFavorite,
                        intervalPriceUpdatingObservable: oldViewModel.intervalPriceUpdatingObservable,
                        profileObservable: oldViewModel.profileObservable)
                    items[index] = .stock(viewModel: newViewModel)
                    current[0] = StocksSection(original: current[0], items: items)
                case let .updatePrice(symbol, price):
                    var items = current[0].items
                    var oldViewModel: StockCellViewModel!
                    guard let index = items
                            .firstIndex(where: { item -> Bool in
                                if case let .stock(viewModel) = item, viewModel.symbol == symbol {
                                    oldViewModel = viewModel
                                    return true
                                } else {
                                    return false
                                }
                            })
                    else { return }
                    let newViewModel = StockCellViewModel(
                        symbol: oldViewModel.symbol,
                        name: oldViewModel.name,
                        price: price,
                        isFavorite: oldViewModel.isFavorite,
                        intervalPriceUpdatingObservable: oldViewModel.intervalPriceUpdatingObservable,
                        profileObservable: oldViewModel.profileObservable)
                    items[index] = .stock(viewModel: newViewModel)
                    current[0] = StocksSection(original: current[0], items: items)
                }
            })
            
            let filteredSections = Observable.combineLatest(
                Observable.merge(
                    Observable.just(()).map { FavoriteListState.unfavorite },
                    favoriteListToggled.filter({ $0 }).map { _ in FavoriteListState.favorite },
                    favoriteListToggled.filter({ !$0 }).map { _ in FavoriteListState.unfavorite }
                ),
                sections
            )
            .scan(into: [StocksSection](arrayLiteral: .stocks(items: [])), accumulator: { current, next in
                switch next.0 {
                case .unfavorite:
                    current[0] = StocksSection(original: current[0], items: next.1[0].items)
                case .favorite:
                    let items = next.1[0].items.compactMap { item -> StocksSectionItem? in
                        if case let .stock(viewModel) = item, viewModel.isFavorite {
                            return item
                        } else {
                            return nil
                        }
                    }
                    current[0] = StocksSection(original: current[0], items: items)
                }
            })
            
            let selected = inputs.select
                .compactMap { item -> (String, String, Observable<StockDetail>)? in
                    if case let .stock(viewModel) = item {
                        return (viewModel.symbol, viewModel.name, viewModel.profileObservable)
                    } else {
                        return nil
                    }
                }
                .asDriver(onErrorJustReturn: ("", "", Observable.empty()))
                .map({ tuple -> Action in
                    Action.stockDetail(
                        symbol: tuple.0,
                        name: tuple.1,
                        profileObservable: tuple.2,
                        intervalPriceUpdateObservable: updatePrice.compactMap({ quote -> Double? in
                            quote.symbol == tuple.0 ? quote.price : nil
                        }))
                })
            
            let settingsAction = inputs.showSettings
                .asDriver(onErrorJustReturn: ())
                .map { Action.settings }
            
            return (
                Outputs(
                    sections: filteredSections,
                    isFavoriteList: favoriteListToggled),
                Driver.merge(selected, settingsAction)
            )
        }
    }
    
    private static func profileObservable(symbol: String) -> Observable<StockDetail> {
        Observable.just(symbol)
            .flatMapLatest({
                URLSession.shared.rx.dataTask(with: Requests.profile(symbol: $0).urlRequest)
            })
            .compactMap { $0.success }
            .map({
                try! JSONDecoder().decode([StockDetail].self, from: $0).first!
            })
            .share(replay: 1, scope: .forever)
    }
}
