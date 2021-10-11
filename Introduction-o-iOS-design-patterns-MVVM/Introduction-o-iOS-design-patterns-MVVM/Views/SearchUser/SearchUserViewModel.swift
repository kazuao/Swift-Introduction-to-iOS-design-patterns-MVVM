//
//  SearchUserViewModel.swift
//  GitHub
//
//  Created by kazunori.aoki on 2021/10/08.
//  Copyright © 2021 marty-suzuki. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import GitHub

final class SearchUserViewModel {
    private let searchUserModel: SearchUserModelProtocol
    private let disposeBag = DisposeBag()
    
    var users: [User] {
        return _users.value
    }
    
    private let _users = BehaviorRelay<[User]>(value: [])
    
    let deselectRow: Observable<IndexPath>
    let reloadData: Observable<Void>
    let transitionToUserDetail: Observable<GitHub.User.Name>
    
    init(searchBarText: Observable<String?>,
         searchButtonClicked: Observable<Void>,
         itemSelected: Observable<IndexPath>,
         searchUserModel: SearchUserModelProtocol = SearchUserModel())
    {
        self.searchUserModel = searchUserModel
        
        self.deselectRow = itemSelected.map { $0 }
        
        self.reloadData = _users.map { _ in }
        
        self.transitionToUserDetail = itemSelected
            .withLatestFrom(_users) { ($0, $1) }
            .flatMap { indexPath, users -> Observable<GitHub.User.Name> in // .flatMapの返り値は`ObservableConvertibleType
                guard indexPath.row < users.count else { return .empty() } // .flatMapは、map + mergeの処理、Observableがネストしない
                
                return .just(users[indexPath.row].strictName)
            }
        
        let searchResponse = searchButtonClicked
            .withLatestFrom(searchBarText)
            .flatMapFirst { [weak self] text -> Observable<Event<[User]>> in
                guard let _self = self,
                      let query = text else { return .empty() }
                
                return _self.searchUserModel
                    .fetchUser(query: query)
                    .materialize()
            }
        // .share()でHotに変換することで、後の
        // ・ストリームを分割
            .share()
        
        searchResponse
            .flatMap { event -> Observable<[User]> in
                event.element.map(Observable.just) ?? .empty()
            }
            .bind(to: _users)
            .disposed(by: disposeBag)
        
        searchResponse
            .flatMap { event -> Observable<Error> in
                event.error.map(Observable.just) ?? .empty()
            }
            .subscribe(onNext: { error in
                // TODO: error handling
            })
            .disposed(by: disposeBag)
    }
}
