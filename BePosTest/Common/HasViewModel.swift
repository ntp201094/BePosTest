//
//  HasViewModel.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 16/03/2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol HasViewModel: AnyObject {
    associatedtype Inputs
    associatedtype Outputs
    var viewModel: (Inputs) -> Outputs { get set }
}

protocol ViewModelType {
    associatedtype Inputs
    associatedtype Outputs
    associatedtype Action
}

extension HasViewModel {
    func installViewModel<Action>(_ transform: @escaping (Inputs) -> (Outputs, Driver<Action>)) -> Driver<Action> {
        let result = PublishSubject<Action>()
        self.viewModel = { inputs in
            let tuple = transform(inputs)
            _ = tuple.1.drive(result)
            return tuple.0
        }
        return result.asDriver(onErrorRecover: { fatalError("\($0.localizedDescription)") })
    }
}
