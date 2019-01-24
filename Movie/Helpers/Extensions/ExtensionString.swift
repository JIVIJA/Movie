//
//  ExtensionString.swift
//  Movie
//
//  Created by mac-0007 on 23/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import Foundation

extension String {
    
    var trimmingByWhitespaces: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isBlank: Bool {
        return self.trimmingByWhitespaces.isEmpty
    }
}
