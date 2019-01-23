//
//  SearchVC.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import UIKit

class SearchVC: ParentVC {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblResults: UITableView!
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    
    //MARK:- General Methods
    private func configure() {
        
        //...TitleView
        navigationItem.titleView = searchBar
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.tintColor = .blue
            textField.layer.cornerRadius = 18.0
            textField.clipsToBounds = true
        }
        
        
        //...
        
    }
}


//MARK:-
//MARK:- UISearchBarDelegate
extension SearchVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
