//
//  UIKit+Hepler.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 17/03/2021.
//

import UIKit

extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        self.init(x: x, y: y, width: w, height: h)
    }
}

extension UIViewController {
    static func top() -> UIViewController {
        guard let rootViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else { fatalError("No view controller present in app?") }
        var result = rootViewController
        while let vc = result.presentedViewController {
            result = vc
        }

        if let navigation = result as? UINavigationController {
            result = navigation.topViewController ?? navigation
        }
        return result
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
