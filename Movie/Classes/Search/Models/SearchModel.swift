//
//  SearchModel.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import Foundation
import CoreData
import RxDataSources
import RxCoreData

struct SearchModel {
    var keyword: String
    var timestamp: Double
}

extension SearchModel: Equatable {
    static func == (lhs: SearchModel, rhs: SearchModel) -> Bool {
        return lhs.keyword == rhs.keyword
    }
}

extension SearchModel: IdentifiableType {
    typealias Identity = String
    var identity: Identity { return keyword }
}

extension SearchModel: Persistable {
    
    typealias T = NSManagedObject
    
    static var entityName: String {
        return "SearchHistory"
    }
    
    static var primaryAttributeName: String {
        return "keyword"
    }
    
    init(entity: T) {
        keyword = entity.value(forKey: "keyword") as! String
        timestamp = entity.value(forKey: "timestamp") as! Double
    }
    
    func update(_ entity: T) {
        entity.setValue(timestamp, forKey: "timestamp")
        entity.setValue(keyword, forKey: "keyword")
        
        do {
            try entity.managedObjectContext?.save()
        } catch let e {
            print(e)
        }
    }
    
}
