//
//  MovieModel.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData
import RxDataSources
import RxCoreData

struct MovieModel: Mappable {
    
    var id: String?
    var title: String?
    var genres: [Any]?
    var ageCategory: String?
    var rate: Double?
    var releaseDate: Double?
    var posterPath: String?
    var presaleFlag: Int16?
    var movieDescription: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        genres <- map["genre_ids"]
        ageCategory <- map["age_category"]
        rate <- map["rate"]
        releaseDate <- map["release_date"]
        posterPath <- map["poster_path"]
        presaleFlag <- map["presale_flag"]
        movieDescription <- map["description"]
    }
}

extension MovieModel: Equatable {
    static func == (lhs: MovieModel, rhs: MovieModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension MovieModel: IdentifiableType {
    typealias Identity = String
    var identity: Identity { return id ?? ""}
}

extension MovieModel: Persistable {
    
    typealias T = NSManagedObject
    
    static var entityName: String {
        return "Movie"
    }
    
    static var primaryAttributeName: String {
        return "id"
    }
    
    init(entity: T) {
        id                  = entity.value(forKey: "id") as? String
        title               = entity.value(forKey: "title") as? String
        genres              = entity.value(forKey: "genres") as? [Any]
        ageCategory         = entity.value(forKey: "ageCategory") as? String
        rate                = entity.value(forKey: "rate") as? Double
        releaseDate         = entity.value(forKey: "releaseDate") as? Double
        posterPath          = entity.value(forKey: "posterPath") as? String
        presaleFlag         = entity.value(forKey: "presaleFlag") as? Int16
        movieDescription    = entity.value(forKey: "movieDescription") as? String
    }
    
    func update(_ entity: T) {
        entity.setValue(id, forKey: "id")
        entity.setValue(title, forKey: "title")
        entity.setValue(genres, forKey: "genres")
        entity.setValue(rate, forKey: "rate")
        entity.setValue(releaseDate, forKey: "releaseDate")
        entity.setValue(posterPath, forKey: "posterPath")
        entity.setValue(presaleFlag, forKey: "presaleFlag")
        entity.setValue(movieDescription, forKey: "movieDescription")
        
        do {
            try entity.managedObjectContext?.save()
        } catch let e {
            print(e)
        }
    }
    
}
