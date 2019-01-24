//
//  SearchVC.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxCoreData
import RxDataSources
import CoreData

class SearchVC: ParentVC {
    
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    @IBOutlet fileprivate weak var tblResults: UITableView! {
        didSet {
            tblResults.register(UITableViewCell.self, forCellReuseIdentifier: "SearchTVCell")
        }
    }
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    
    //MARK:- General Methods
    private func configure() {
        
        //...Set SearchBar in navigationItem's titleView
        searchBar.heightAnchor.constraint(equalToConstant: navigationController?.navigationBar.frame.size.height ?? 44).isActive = true
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.tintColor = .blue
            textField.layer.cornerRadius = 18.0
            textField.clipsToBounds = true
        }
        navigationItem.titleView = searchBar
        
        
        
        //...DataSource.
        let animatedDataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, SearchModel>>(configureCell: { dateSource, tableView, indexPath, searchModel in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTVCell", for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.text = "\(searchModel.keyword)"
            return cell
        }, canEditRowAtIndexPath: {_, _ in
            return true
        })
        
        
        
        //...Fetch recent search history from coredata and observe it.
        CAppdelegate?.persistentContainer.viewContext.rx.entities(SearchModel.self, sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]).map { results in
            [AnimatableSectionModel(model: "", items: results)]
            }.bind(to: tblResults.rx.items(dataSource: animatedDataSource)).disposed(by: disposeBag)
        
        
        
        //...Swipe to delete
        tblResults.rx.itemDeleted.map { [unowned self] indexPath -> SearchModel in
            return try self.tblResults.rx.model(at: indexPath)
            }.subscribe(onNext: { (searchHistory) in
                do {
                    try CAppdelegate?.persistentContainer.viewContext.rx.delete(searchHistory)
                } catch {
                    print(error)
                }
            }).disposed(by: disposeBag)
        
        
        
        //...UITableView row selection.
        Observable.zip(tblResults.rx.itemSelected, tblResults.rx.modelSelected(SearchModel.self)).bind { indexPath, searchModel in
                let listVC = ListVC(nibName: "ListVC", bundle: nil)
                self.navigationController?.pushViewController(listVC, animated: true)
            }.disposed(by: disposeBag)
    }
}



//MARK:-
//MARK:- UISearchBarDelegate
extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let keyword = searchBar.text, !keyword.isBlank {
            SearchViewModel.shared.add(keyword: keyword)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
