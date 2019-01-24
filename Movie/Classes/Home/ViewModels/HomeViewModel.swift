//
//  HomeViewModel.swift
//  Movie
//
//  Created by mac-00017 on 23/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

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
    
    var arrMovies:Variable<[MovieLists]> = Variable([])
    var needToStartTimer:Variable<Bool> = Variable(false)
}


// MARK: -
// MARK: - General Methods.

extension HomeViewModel {
    
    func loadMovieLists() {
        
        _ = APIRequest.shared.movieLists(successCompletion: { (response, status) in
            self.getAllLocalMovieData()
        }, failureCompletion: nil)
    }
    
    func showMovieDetails(index:Int) -> (strName:String , strType:String) {
        let movieDetails = arrMovies.value[index]
        return (movieDetails.title ?? "" , movieDetails.genre_ids as! String )
    }
    
    func getAllLocalMovieData() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieLists")
        
        do {
            if let arrMovieLists = try CAppdelegate?.persistentContainer.viewContext.fetch(fetchRequest) as? [MovieLists]{
                arrMovies.value = arrMovieLists
            }
        } catch {
            print(error)
        }
    }
}
