//
//  ViewController.swift
//  Introduction-o-iOS-design-patterns-MVVM
//
//  Created by kazunori.aoki on 2021/10/08.
//

import UIKit
import RxSwift
import RxCocoa
import GitHub

class SearchUserViewController: UIViewController {

    // MARK: UI
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    
    // MARK: Variable
    private lazy var viewModel = SearchUserViewModel(
        searchBarText: searchBar.rx.text.asObservable(),
        searchButtonClicked: searchBar.rx.searchButtonClicked.asObservable(),
        itemSelected: tableView.rx.itemSelected.asObservable()
    )
    private let disposeBag = DisposeBag()
    
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}


// MARK: - Setup
private extension SearchUserViewController {
    
    func setup() {
        setupBind()
        setupView()
    }
    
    func setupBind() {
        viewModel.deselectRow
            .bind(to: deselectRow)
            .disposed(by: disposeBag)
        
        viewModel.reloadData
            .bind(to: reloadData)
            .disposed(by: disposeBag)

        viewModel.transitionToUserDetail
            .bind(to: transitionToUserDetail)
            .disposed(by: disposeBag)
    }
    
    func setupView() {
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
}


// MARK: - Private
private extension SearchUserViewController {
    var deselectRow: Binder<IndexPath> {
        return Binder(self) { me, IndexPath in
            me.tableView.deselectRow(at: IndexPath, animated: true)
        }
    }
    
    var reloadData: Binder<Void> {
        return Binder(self) { me, _ in
            me.tableView.reloadData()
        }
    }
    
    var transitionToUserDetail: Binder<(GitHub.User.Name)> {
        return Binder(self) { me, userName in
//            let userDetailVC = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController() as! UserDetailViewController
//            userDetailVC.userName = userName
//            me.navigationController?.pushViewController(userDetailVC, animated: true)
        }
    }
}


// MARK: - UITableViewDataSource
extension SearchUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell

        let user = viewModel.users[indexPath.row]
        cell.configure(user: user)

        return cell
    }
}


