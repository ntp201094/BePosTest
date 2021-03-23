//
//  MainCoordinator.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 17/03/2021.
//

import UIKit
import RxSwift

func mainCoordinator(window: UIWindow) {
    let stocksVC = StocksViewController()
    _ = stocksVC.installViewModel(StocksViewModel.viewModel())
        .drive(onNext: { action in
            switch action {
            case let .stockDetail(symbol, name, profileObservable, priceUpdateObservable):
                showStockDetail(symbol: symbol, name: name, profileObservable: profileObservable, priceUpdateObservable: priceUpdateObservable)
            case .settings:
                settingsCoordinator()
            }
        })
    
    let stocksNav = UINavigationController(rootViewController: stocksVC)
    window.rootViewController = stocksNav
    window.makeKeyAndVisible()
}

func showStockDetail(symbol: String, name: String, profileObservable: Observable<StockDetail>, priceUpdateObservable: Observable<Double>) {
    let stockDetailVC = StockDetailViewController()
    _ = stockDetailVC.installViewModel(StockDetailViewModel.viewModel(symbol: symbol, name: name, profileObservable: profileObservable, priceUpdateObservable: priceUpdateObservable))
        .drive(onNext: { action in
            
        })
    
    UIViewController.top().show(stockDetailVC, sender: nil)
}
