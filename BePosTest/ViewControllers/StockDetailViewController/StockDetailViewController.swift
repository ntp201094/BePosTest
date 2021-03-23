//
//  StockDetailViewController.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 18/03/2021.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import HITChartSwift

final class StockDetailViewController: UIViewController, HasViewModel {
    
    var viewModel: (StockDetailViewModel.Inputs) -> StockDetailViewModel.Outputs = { _ in fatalError("Missing view model of \(String(describing: self)).") }
    
    private weak var companyImageView: UIImageView!
    private weak var changesLabel: UILabel!
    private weak var symbolLabel: UILabel!
    private weak var nameLabel: UILabel!
    private weak var priceLabel: UILabel!
    private weak var lastDivLabel: UILabel!
    private weak var sectorLabel: UILabel!
    private weak var industryLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    private weak var chartView: HITCandlestickChartView!
    private weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.bindViewModel()
    }

}

// MARK: - Private Methods
private extension StockDetailViewController {
    func setupViews() {
        self.view.backgroundColor = .systemBackground
        
        let companyImageView = UIImageView(image: nil)
        companyImageView.translatesAutoresizingMaskIntoConstraints = false
        companyImageView.contentMode = .scaleAspectFit
        self.view.addSubview(companyImageView)
        self.companyImageView = companyImageView
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        self.view.addSubview(stackView)
        
        let changesLabel = UILabel()
        changesLabel.translatesAutoresizingMaskIntoConstraints = false
        changesLabel.text = nil
        stackView.addArrangedSubview(changesLabel)
        self.changesLabel = changesLabel
        
        let symbolLabel = UILabel()
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.text = nil
        stackView.addArrangedSubview(symbolLabel)
        self.symbolLabel = symbolLabel
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = nil
        nameLabel.numberOfLines = 0
        nameLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        stackView.addArrangedSubview(nameLabel)
        self.nameLabel = nameLabel
        
        let priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = nil
        stackView.addArrangedSubview(priceLabel)
        self.priceLabel = priceLabel
        
        let lastDivLabel = UILabel()
        lastDivLabel.translatesAutoresizingMaskIntoConstraints = false
        lastDivLabel.text = nil
        stackView.addArrangedSubview(lastDivLabel)
        self.lastDivLabel = lastDivLabel
        
        let sectorLabel = UILabel()
        sectorLabel.translatesAutoresizingMaskIntoConstraints = false
        sectorLabel.text = nil
        stackView.addArrangedSubview(sectorLabel)
        self.sectorLabel = sectorLabel
        
        let industryLabel = UILabel()
        industryLabel.translatesAutoresizingMaskIntoConstraints = false
        industryLabel.text = nil
        stackView.addArrangedSubview(industryLabel)
        self.industryLabel = industryLabel
        
        NSLayoutConstraint.activate([
            companyImageView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            companyImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            companyImageView.widthAnchor.constraint(equalToConstant: 128.0),
            companyImageView.heightAnchor.constraint(equalToConstant: 128.0),
            stackView.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 16.0),
            stackView.centerYAnchor.constraint(equalTo: companyImageView.centerYAnchor),
            stackView.trailingAnchor.constraint(greaterThanOrEqualTo: self.view.layoutMarginsGuide.trailingAnchor)
            
        ])
        
        let segmentedControl = UISegmentedControl(items: PeriodOption.allCases.map { NSString(string: $0.name) })
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        self.view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            segmentedControl.topAnchor.constraint(equalTo: companyImageView.bottomAnchor, constant: 16),
        ])
        self.segmentedControl = segmentedControl
        
        let chartView = HITCandlestickChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(chartView)
        
        NSLayoutConstraint.activate([
            chartView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            chartView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            chartView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            chartView.heightAnchor.constraint(equalToConstant: 250)
        ])
        self.chartView = chartView
    }
    
    func bindViewModel() {
        let inputs = StockDetailViewModel.Inputs(
            selectOption: self.segmentedControl.rx.value.compactMap({ PeriodOption(rawValue: $0) }).asObservable()
        )
        let outputs = self.viewModel(inputs)
        outputs.image
            .asDriver(onErrorJustReturn: nil)
            .drive(self.companyImageView.rx.imageURL(withPlaceholder: UIImage(systemName: "rectangle"), options: [.transition(ImageTransition.fade(1))]))
            .disposed(by: self.disposeBag)
        outputs.changes
            .asDriver(onErrorJustReturn: "")
            .drive(self.changesLabel.rx.text)
            .disposed(by: self.disposeBag)
        outputs.changesColor
            .asDriver(onErrorJustReturn: .black)
            .drive(self.changesLabel.rx.textColor)
            .disposed(by: self.disposeBag)
        outputs.symbol
            .asDriver(onErrorJustReturn: "")
            .drive(self.symbolLabel.rx.text)
            .disposed(by: self.disposeBag)
        outputs.name
            .asDriver(onErrorJustReturn: "")
            .drive(self.nameLabel.rx.text)
            .disposed(by: self.disposeBag)
        outputs.price
            .asDriver(onErrorJustReturn: 0)
            .map { "\($0)" }
            .drive(self.priceLabel.rx.text)
            .disposed(by: self.disposeBag)
        outputs.lastDiv
            .asDriver(onErrorJustReturn: "")
            .drive(self.lastDivLabel.rx.text)
            .disposed(by: self.disposeBag)
        outputs.sector
            .asDriver(onErrorJustReturn: "")
            .drive(self.sectorLabel.rx.text)
            .disposed(by: self.disposeBag)
        outputs.industry
            .asDriver(onErrorJustReturn: "")
            .drive(self.industryLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        outputs.histories
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] histories in
                guard let self = self else { return }
                let maxChange = abs(histories.map{ $0.change }.max() ?? 0.0).rounded(.up)
                let minChange = abs(histories.map{ $0.change }.min() ?? 0.0).rounded(.up)
                let absMaxPercentage = Int(maxChange > minChange ? maxChange : minChange)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                self.chartView.draw(
                    absMaxPercentage,
                    values: histories.map { (close: $0.close, open: $0.open, high: $0.high, low: $0.low) },
                    label: (max: "+\(absMaxPercentage)%", center: "0%", min: "-\(absMaxPercentage)%"),
                    dates: histories.map { dateFormatter.date(from: $0.date) ?? Date() },
                    titles: histories.map { "Open: \($0.open), close: \($0.close), high: \($0.high), low: \($0.low), change: \($0.change), volume: \($0.volume)" })
            })
            .disposed(by: self.disposeBag)
    }
}
