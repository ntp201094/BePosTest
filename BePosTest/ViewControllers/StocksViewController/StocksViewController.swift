//
//  StocksViewController.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 16/03/2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

final class StocksViewController: UITableViewController, HasViewModel {
    var viewModel: (StocksViewModel.Inputs) -> StocksViewModel.Outputs = { _ in fatalError("Missing view model of \(String(describing: self)).") }
    
    private weak var favoriteButton: UIButton!
    private weak var settingsButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let favoriteTrigger = PublishSubject<String>()
    private let unfavoriteTrigger = PublishSubject<String>()
    private let updatePriceTrigger = PublishSubject<String>()
    
    deinit {
        favoriteTrigger.onCompleted()
        unfavoriteTrigger.onCompleted()
        updatePriceTrigger.onCompleted()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.bindViewModel()
    }
    
}

// MARK: - Private Methods
private extension StocksViewController {
    func setupViews() {
        self.title = "Stocks"
        
        let favoriteButton = UIButton(type: .system)
        favoriteButton.setTitle("Favorite", for: .normal)
        favoriteButton.setTitle("All", for: .selected)
        self.favoriteButton = favoriteButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: favoriteButton)
        
        let settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Settings", for: .normal)
        self.settingsButton = settingsButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
        self.tableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingCell")
        self.tableView.register(UINib(nibName: "StockTableViewCell", bundle: nil), forCellReuseIdentifier: "StockCell")
        
        self.tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindViewModel() {
        let inputs = StocksViewModel.Inputs(
            select: self.tableView.rx.modelSelected(StocksSectionItem.self).asObservable(),
            favoriteItem: self.favoriteTrigger.asObservable(),
            unfavoriteItem: self.unfavoriteTrigger.asObservable(),
            favoriteListToggle: self.favoriteButton.rx.tap.asObservable(),
            updatePrice: self.updatePriceTrigger.asObservable(),
            showSettings: self.settingsButton.rx.tap.asObservable()
        )
        let outputs = self.viewModel(inputs)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<StocksSection>(animationConfiguration: AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade), configureCell: { [weak self] dataSource, tableView, indexPath, item -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }
            switch item {
            case .loading:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as? LoadingTableViewCell else {
                    fatalError("Dequeue loading cell failed.")
                }
                cell.indicatorView?.startAnimating()
                
                return cell
            case .stock(let viewModel):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as? StockTableViewCell else {
                    fatalError("Dequeue loading cell failed.")
                }
                cell.configure(viewModel: viewModel)
                let symbol = viewModel.symbol
                viewModel.intervalPriceUpdatingObservable
                    .subscribe(onNext: { [weak self] _ in
                        self?.updatePriceTrigger.onNext(symbol)
                    })
                    .disposed(by: cell.disposeBag)
                
                viewModel.profileObservable
                    .map { URL(string: $0.image) }
                    .asDriver(onErrorJustReturn: nil)
                    .drive(cell.companyImageView.rx.imageURL(withPlaceholder: UIImage(systemName: "rectangle"), options: [.transition(ImageTransition.fade(1))]))
                    .disposed(by: cell.disposeBag)
                
                viewModel.profileObservable
                    .map { "\($0.changes)" }
                    .asDriver(onErrorJustReturn: "")
                    .drive(cell.changesLabel.rx.text)
                    .disposed(by: cell.disposeBag)
                
                viewModel.profileObservable
                    .map { $0.changes > 0 ? UIColor.green : UIColor.red }
                    .asDriver(onErrorJustReturn: .black)
                    .drive(cell.changesLabel.rx.textColor)
                    .disposed(by: cell.disposeBag)
                
                cell.favoriteButton.rx.tap
                    .asObservable()
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        if viewModel.isFavorite {
                            self.unfavoriteTrigger.onNext(symbol)
                        } else {
                            self.favoriteTrigger.onNext(symbol)
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
        })
        
        outputs.sections
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        outputs.isFavoriteList
            .asDriver(onErrorJustReturn: false)
            .drive(self.favoriteButton.rx.isSelected)
            .disposed(by: self.disposeBag)
    }
}
