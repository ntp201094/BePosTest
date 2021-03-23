//
//  RxSwift+Operators.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 18/03/2021.
//

import RxSwift
import Kingfisher

extension Observable {
    func asVoid() -> Observable<Void> {
        self.map { _ in }
    }
}

extension Reactive where Base: UIImageView {

    public var imageURL: Binder<URL?> {
        return self.imageURL(withPlaceholder: nil)
    }

    public func imageURL(withPlaceholder placeholderImage: UIImage?, options: KingfisherOptionsInfo? = []) -> Binder<URL?> {
        return Binder(self.base, binding: { (imageView, url) in
            imageView.kf.setImage(with: url,
                                  placeholder: placeholderImage,
                                  options: options,
                                  progressBlock: nil,
                                  completionHandler: { (result) in })
        })
    }
}
