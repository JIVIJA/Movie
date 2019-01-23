//
//  HomeViewModel.swift
//  Movie
//
//  Created by mac-00017 on 23/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import Foundation
import RxSwift

class  HomeViewModel {
    
    // MARK: -
    // MARK: - Singleton.
    private init() {}
    
    private static var homeViewModel: HomeViewModel = {
        let homeViewModel = HomeViewModel()
        return homeViewModel
    }()
    
    static var shared: HomeViewModel {
        return homeViewModel
    }
    
    // MARK: -
    // MARK: - Rx-Swift Observable.
    
    var arrMovies:Variable<[MovieList]> = Variable([])
    
}


// MARK: -
// MARK: - General Methods.

extension HomeViewModel {
    
    func loadMovieLists() {
        
        _ = APIRequest.shared.movieLists(successCompletion: { (response, status) in
            
        }, failureCompletion: nil)
    }
}
