//
//  MovieViewModel.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

enum MovieType: String {
    case nowShowing = "nowshowing"
    case comingSoon = "comingsoon"
}

class MovieViewModel {
    
    var apiSearchMovies: URLSessionTask?
    var apiLoadMoreMovies: URLSessionTask?
    
    //MARK:- RxSwift Observable
    var arrNowShowingMovies: Variable<[MovieModel]> = Variable([])
    var arrComingSoonMovies: Variable<[MovieModel]> = Variable([])
    var arrMovies: Variable<[MovieModel]> = Variable([])
    
    
    // MARK: - Singleton.
    private init() {}
    
    static var shared: MovieViewModel = {
        return MovieViewModel()
    }()
}

extension MovieViewModel {
    
    func searchMovies(byKeyword keyword: String) {
        
        if let api = apiSearchMovies, api.state == .running {
            api.cancel()
        }
        
        //...Offset 0 - RemoveAll
        self.arrMovies.value.removeAll()
        self.arrNowShowingMovies.value.removeAll()
        self.arrComingSoonMovies.value.removeAll()
        
        
        apiSearchMovies = APIRequest.shared.searchMovie(byKeyword: keyword, offset: 0, successCompletion: { (response, status) in
            
            if let response = response as? [String: Any], let result = response["results"] as? [String: Any] {
                if let movies = result["upcoming"] as? [[String: Any]] {
                    self.arrNowShowingMovies.value += Mapper<MovieModel>().mapArray(JSONArray: movies)
                }
                
                if let movies = result["showing"] as? [[String: Any]] {
                    self.arrComingSoonMovies.value += Mapper<MovieModel>().mapArray(JSONArray: movies)
                }
            }
            
        }, failureCompletion: nil)
    }
    
    func loadMovies(byKeyword keyword: String, type: MovieType = .nowShowing) {
        
        if let api = apiSearchMovies, api.state == .running {
            api.cancel()
        }
        
        if let api = apiLoadMoreMovies, api.state == .running {
            api.cancel()
        }
        
        apiLoadMoreMovies = APIRequest.shared.movieList(
            byKeyword: keyword,
            type: type.rawValue,
            offset: type == .nowShowing ? arrNowShowingMovies.value.count : arrComingSoonMovies.value.count,
            successCompletion: { (response, status) in
                
                if let response = response as? [String: Any], let movies = response["results"] as? [[String: Any]] {
                    if type == .nowShowing {
                        self.arrNowShowingMovies.value += Mapper<MovieModel>().mapArray(JSONArray: movies)
                    } else {
                        self.arrComingSoonMovies.value += Mapper<MovieModel>().mapArray(JSONArray: movies)
                    }
                }
                
        }, failureCompletion: nil)
    }
}

extension MovieViewModel {
    func stringReleaseDate(fromTimeInterval timeInterval: Double) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd MMM yyyy"
        return dateFormater.string(from: Date(timeIntervalSince1970: timeInterval))
    }
}
