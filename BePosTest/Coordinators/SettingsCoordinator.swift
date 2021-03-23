//
//  SettingsCoordinator.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 17/03/2021.
//

import UIKit

func settingsCoordinator() {
    let isDarkMode = UIApplication.shared.windows.first!.overrideUserInterfaceStyle == .dark ? true : false
    let settingsVC = SettingsViewController()
    _ = settingsVC.installViewModel(SettingsViewModel.viewModel(isDarkMode: isDarkMode))
        .drive(onNext: { action in
            switch action {
            case .close:
                UIViewController.top().dismiss(animated: true)
            }
        })
    let settingsNav = UINavigationController(rootViewController: settingsVC)
    UIViewController.top().present(settingsNav, animated: true)
}
