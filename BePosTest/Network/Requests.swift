//
//  Requests.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 18/03/2021.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: URLSession {
    func dataTask(with request: URLRequest) -> Observable<Result<Data>> {
        return URLSession.shared.rx.data(request: request)
            .materialize()
            .filter { $0.isCompleted == false }
            .map { $0.asResult }
    }
}

extension Event {
    var asResult: Result<Element> {
        switch self {
        case .next(let element):
            return .success(element)
        case .error(let error):
            return .error(error)
        case .completed:
            fatalError("This case never happen.")
        }
    }
}

enum Requests {
    case stocks
    case histories(symbol: String, from: Date, to: Date)
    case currentPrice(symbol: String)
    case profile(symbol: String)
    
    var baseURLString: String { return Configuration.baseURLString }
    
    var path: String {
        var path = "/api/v3"
        switch self {
        case .stocks:
            path += "/stock/list"
        case .histories(let symbol, _, _):
            path += "/historical-price-full/\(symbol)"
        case .currentPrice(let symbol):
            path += "/quote-short/\(symbol)"
        case .profile(let symbol):
            path += "/profile/\(symbol)"
        }
        
        return path
    }
    
    var queryItems: [URLQueryItem] {
        var queryItems = [URLQueryItem(name: "apikey", value: Configuration.apiKey)]
        switch self {
        case .stocks:
            break
        case let .histories(_, from, to):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            queryItems += [
                URLQueryItem(name: "from", value: dateFormatter.string(from: from)),
                URLQueryItem(name: "to", value: dateFormatter.string(from: to))
            ]
        case .currentPrice:
            break
        case .profile:
            break
        }
        
        return queryItems
    }
    
    var urlRequest: URLRequest {
        var components = URLComponents(string: baseURLString)!
        components.path = self.path
        components.queryItems = self.queryItems
        var request = URLRequest(url: components.url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
}
