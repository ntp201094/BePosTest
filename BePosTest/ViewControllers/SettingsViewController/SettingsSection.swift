//
//  SettingsSection.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 22/03/2021.
//

import Foundation
import RxDataSources

enum SettingsSection {
    case settings(items: [SettingsSectionItem])
}

enum SettingsSectionItem {
    case modeSwitcher(isDark: Bool)
    case version(text: String)
}

extension SettingsSection: SectionModelType {
    var items: [SettingsSectionItem] {
        switch self {
        case .settings(let items):
            return items
        }
    }
    
    init(original: SettingsSection, items: [SettingsSectionItem]) {
        switch original {
        case .settings:
            self = .settings(items: items)
        }
    }
}
