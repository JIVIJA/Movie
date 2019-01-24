//
//  HomeModel.swift
//  Movie
//
//  Created by mac-00017 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData
import RxDataSources
import RxCoreData

struct MovieList : Mappable  {
    
    var id:String?
    var title:String?
    var genre_ids:Any?
    var poster_path:String?
    var release_date:Int64?
    var presale_flag:Int64?
    var rate:Float?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        rate <- map["rate"]
        release_date <- map["release_date"]
        poster_path <- map["poster_path"]
        presale_flag <- map["presale_flag"]
        genre_ids <- map["genre_ids"]
        
    }
}

struct Movie : Mappable  {
    
    var results:[MovieList]?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        results <- map["results"]
    }
}

// MARK: - RXCore Data

func == (lhs: MovieList, rhs: MovieList) -> Bool {
    return lhs.id == rhs.id
}

extension MovieList : Equatable { }

extension MovieList : IdentifiableType {
    typealias Identity = String
    
    var identity: Identity { return id ?? ""}
}

extension MovieList : Persistable {
    typealias T = NSManagedObject
    
    static var entityName: String {
        return "MovieLists"
    }
    
    static var primaryAttributeName: String {
        return "id"
    }
    
    init(entity: T) {

        genre_ids = entity.value(forKey: "genre_ids") as Any
        id = entity.value(forKey: "id") as? String
        title = entity.value(forKey: "title") as? String
        poster_path = entity.value(forKey: "poster_path") as? String
        release_date = entity.value(forKey: "release_date") as? Int64
        presale_flag = entity.value(forKey: "presale_flag") as? Int64
        rate = entity.value(forKey: "release_date") as? Float
    }
    
    func update(_ entity: T) {
        
        var movieType:String {
            if let arrGenreIds = genre_ids as? [[String:AnyObject]]{
                return arrGenreIds.map({($0["name"] as? String) ?? ""}).joined(separator: ",")
            }
            return ""
        }
        
        entity.setValue(id, forKey: "id")
        entity.setValue(title, forKey: "title")
        entity.setValue(poster_path, forKey: "poster_path")
        entity.setValue(release_date, forKey: "release_date")
        entity.setValue(presale_flag, forKey: "presale_flag")
        entity.setValue(rate, forKey: "rate")
        entity.setValue(movieType, forKey: "genre_ids")
        do {
            try entity.managedObjectContext?.save()
        } catch let e {
            print(e)
        }
    }
    
}
