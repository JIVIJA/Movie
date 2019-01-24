//
//  SearchViewModel.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class SearchViewModel {
    
    fileprivate var maxNumberOfRecentlySearchRecord = 10
    
    //MARK:- Singleton
    private init() {}
    
    static var shared: SearchViewModel = {
        return SearchViewModel()
    }()
    
}

extension SearchViewModel {
    func add(keyword: String) {
        if let managedObjectContext = CAppdelegate?.persistentContainer.viewContext {
            try? managedObjectContext.rx.update(SearchModel(keyword: keyword, timestamp: Date().timeIntervalSince1970))
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: SearchModel.entityName)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            do {
                if let results = try managedObjectContext.fetch(fetchRequest) as? [SearchHistory], results.count > maxNumberOfRecentlySearchRecord {
                    
                    for index in maxNumberOfRecentlySearchRecord..<results.count {
                        managedObjectContext.delete(results[index])
                    }
                }
            } catch {
                
            }
        }
    }
}
