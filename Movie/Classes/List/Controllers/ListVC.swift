//
//  ListVC.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import UIKit
import RxSwift

class ListVC: ParentVC {

    @IBOutlet fileprivate weak var btnNowShowing: UIButton!
    @IBOutlet fileprivate weak var btnComingSoon: UIButton!
    @IBOutlet fileprivate weak var cnstLeadingSelectedType: NSLayoutConstraint!
    @IBOutlet fileprivate weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var tblMovies: UITableView! {
        didSet {
            tblMovies.estimatedRowHeight = 100.0
            tblMovies.rowHeight = UITableView.automaticDimension
            tblMovies.register(UINib(nibName: "MovieTVCell", bundle: nil), forCellReuseIdentifier: "MovieTVCell")
        }
    }
    
    var searchKeyword = ""
    fileprivate lazy var dataModel = { return MovieViewModel.shared }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    //MARK:- General Methods
    func configure() {
        dataModel.searchMovies(byKeyword: searchKeyword)
        
        //...
        dataModel.arrNowShowingMovies.asObservable().subscribe(onNext: { (movies) in
            if self.btnNowShowing.isSelected {
                self.dataModel.arrMovies.value = movies
            }
        }).disposed(by: disposeBag)
        
        dataModel.arrComingSoonMovies.asObservable().subscribe(onNext: { (movies) in
            if self.btnComingSoon.isSelected {
                self.dataModel.arrMovies.value = movies
            }
        }).disposed(by: disposeBag)
        
        
        //... Observing dataModel arrMovies.
        let moviesDataObserver = dataModel.arrMovies.asObservable()
        
        moviesDataObserver.subscribe(onNext: { (movies) in
            if movies.count > 0 {
                self.activityIndicatorView.stopAnimating()
                self.tblMovies.isHidden = false
            }
        }).disposed(by: disposeBag)
        
        moviesDataObserver.bind(to: tblMovies.rx.items(cellIdentifier: "MovieTVCell", cellType:MovieTVCell.self)) { (row, movie, cell) in
            cell.configure(movie: movie)
            
            if row == max(0, self.tblMovies.numberOfRows(inSection: 0) - 1) {
                self.dataModel.loadMovies(byKeyword: self.searchKeyword, type: self.btnNowShowing.isSelected ? .nowShowing : .comingSoon)
            }
            
            }.disposed(by: disposeBag)
    }
    
}


//MARK:-
//MARK:- Action Events
extension ListVC {
    
    @IBAction func btnTabClicked(_ sender: UIButton) {
        
        guard !sender.isSelected else {
            return
        }
        
        btnNowShowing.isSelected = false
        btnComingSoon.isSelected = false
        sender.isSelected = true
        
        
        //...Animation
        UIApplication.shared.beginIgnoringInteractionEvents()
        UIView.animate(withDuration: 0.3, animations: {
            self.cnstLeadingSelectedType.constant = sender.frame.origin.x
            self.view.layoutIfNeeded()
        }) { (finished) in
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if self.btnNowShowing.isSelected {
                self.dataModel.arrMovies.value = self.dataModel.arrNowShowingMovies.value
            } else {
                self.dataModel.arrMovies.value = self.dataModel.arrComingSoonMovies.value
            }
            
        }
        
    }
}
