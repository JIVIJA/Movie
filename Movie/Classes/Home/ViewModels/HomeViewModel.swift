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

class HomeViewModel {
    
    // MARK: - Singleton.
    private init() {}
    
    static var shared: HomeViewModel = {
        return HomeViewModel()
    }()
    
    
    //MARK:- Rx-Swift Observable.
    var arrMovies: Variable<[Movie]> = Variable([])
    var needToStartTimer: Variable<Bool> = Variable(false)
}

extension HomeViewModel {
    
    func loadMovies() {
        APIRequest.shared.movieList(successCompletion: { (response, status) in
            self.getAllLocalMovieData()
        }, failureCompletion: nil)
    }
    
    func showMovieDetail(index: Int) -> (strName: String , strType: String) {
        let movie = arrMovies.value[index]
        
        if let genres = movie.genres as? [[String: AnyObject]] {
            return (movie.title ?? "", genres.map({($0["name"] as? String) ?? ""}).joined(separator: ", "))
        }
        
        return (movie.title ?? "", "")
    }
    
    func getAllLocalMovieData() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        
        do {
            if let arrMovieLists = try CAppdelegate?.persistentContainer.viewContext.fetch(fetchRequest) as? [Movie] {
                arrMovies.value = arrMovieLists
            }
        } catch {
            print(error)
        }
    }
}
