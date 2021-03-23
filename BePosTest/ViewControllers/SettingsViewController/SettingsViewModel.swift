//
//  SettingsViewModel.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 17/03/2021.
//

import Foundation
import RxSwift
import RxCocoa

enum SettingsViewModel: ViewModelType {
    struct Inputs {
        let close: Observable<Void>
        let changeMode: Observable<Bool>
    }
    
    struct Outputs {
        let sections: Observable<[SettingsSection]>
        let modeChanged: Observable<Bool>
    }
    
    enum Action {
        case close
    }
    
    static func viewModel(isDarkMode: Bool) -> (Inputs) -> (Outputs, Driver<Action>) {
        return { inputs in
            
            print(UIApplication.appVersion!)
            let items: [SettingsSectionItem] = [
                .modeSwitcher(isDark: isDarkMode),
                .version(text: UIApplication.appVersion!)
            ]
            
            let sections = Observable.just([SettingsSection.settings(items: items)])
            
            let modeChanged = inputs.changeMode
                .observe(on: MainScheduler.instance)
                .do(onNext: {
                    UserDefaults.standard.set($0, forKey: "UIStyle")
                    UIApplication.shared.windows.first!.overrideUserInterfaceStyle = $0 ? .dark : .light
                })
            
            let close = inputs.close
                .asDriver(onErrorJustReturn: ())
                .map { Action.close }
            
            return (
                Outputs(
                    sections: sections,
                    modeChanged: modeChanged
                ),
                Driver.merge(close)
            )
        }
    }
}
