//
//  Category.swift
//  ShoppingList
//
//  Created by Mihai on 3/18/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation

class Category: Sectionable {
    var name: String
    var location: Int
    var items: [String]
    var ref: Any?
    
    init(name: String, location: Int, items: [String], ref: Any? = nil) {
        self.name = name
        self.location = location
        self.items = items
        self.ref = ref
    }
    
    func keyId() -> String {
        return name
    }
    
    func sectionName() -> String {
        return ""
    }
    
    static func ==(left: Category, right: Category) -> Bool {
        return left.name == right.name
    }
}
