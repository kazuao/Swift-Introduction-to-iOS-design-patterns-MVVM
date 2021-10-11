//
//  SearchUserModelProtocol.swift
//  GitHub
//
//  Created by kazunori.aoki on 2021/10/08.
//  Copyright © 2021 marty-suzuki. All rights reserved.
//

import Foundation
import GitHub
import RxSwift

protocol SearchUserModelProtocol {
    func fetchUser(query: String) -> Observable<[User]>
}

class SearchUserModel: SearchUserModelProtocol {
    let session = Session()
    
    func fetchUser(query: String) -> Observable<[User]> {
        return Observable.create { [weak self] observer in
            let request = SearchUsersRequest(query: query, sort: nil, order: nil, page: nil, perPage: nil)
            let task = self?.session.send(request) { result in
                switch result {
                case .success(let response):
                    observer.onNext(response.0.items)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}
