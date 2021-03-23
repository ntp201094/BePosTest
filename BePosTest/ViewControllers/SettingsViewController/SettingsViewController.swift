//
//  SettingsViewController.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 17/03/2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class SettingsViewController: UITableViewController, HasViewModel {
    
    var viewModel: (SettingsViewModel.Inputs) -> SettingsViewModel.Outputs = { _ in fatalError("Missing view model of \(String(describing: self)).") }
    
    var closeButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let changeModeTrigger = PublishSubject<Bool>()
    private let changeMode = PublishSubject<Bool>()
    
    deinit {
        self.changeMode.onCompleted()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.bindViewModel()
    }
}

// MARK: - Private Methods
private extension SettingsViewController {
    func setupViews() {
        self.title = "Settings"
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        self.closeButton = closeButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
        self.tableView.register(UINib(nibName: "SwitcherTableViewCell", bundle: nil), forCellReuseIdentifier: "ModeCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VersionCell")
    }
    
    func bindViewModel() {
        let inputs = SettingsViewModel.Inputs(
            close: self.closeButton.rx.tap.asObservable(),
            changeMode: self.changeModeTrigger.asObservable()
        )
        let outputs = viewModel(inputs)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SettingsSection> { [weak self] dataSrouce, tableView, indexPath, item -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }
            switch item {
            case .modeSwitcher(let isDark):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ModeCell", for: indexPath) as? SwitcherTableViewCell else {
                    fatalError("Dequeue loading cell failed.")
                }
                cell.configure(isDark: isDark)
                cell.modeSwitcher.rx.controlEvent(.valueChanged)
                    .withLatestFrom(cell.modeSwitcher.rx.isOn)
                    .subscribe(onNext: { [weak self] isOn in
                        self?.changeModeTrigger.onNext(isOn)
                    })
                    .disposed(by: cell.disposeBag)
                
                self.changeMode
                    .asDriver(onErrorJustReturn: false)
                    .drive(cell.modeSwitcher.rx.isOn)
                    .disposed(by: cell.disposeBag)
                
                return cell
            case .version(let text):
                let cell = tableView.dequeueReusableCell(withIdentifier: "VersionCell", for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = "App version:"
                content.secondaryText = text
                cell.contentConfiguration = content
                
                return cell
            }
        }
        
        outputs.sections
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        outputs.modeChanged
            .subscribe(onNext: { [weak self] isOn in
                self?.changeMode.onNext(isOn)
            })
            .disposed(by: self.disposeBag)
            
    }
}
