//
//  Item.swift
//  ShoppingList
//
//  Created by Mihai on 3/25/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation

class Item: Sectionable {
    let name: String
    let lastUsed: Date?
    let category: String
    let ref: Any?
    var usageCount: Int?
    
    init(name: String, lastUsed: Date?, category: String, ref: Any? = nil) {
        self.name = name
        self.lastUsed = lastUsed
        self.category = category
        self.ref = ref
    }
    
    func sectionName() -> String {
        return ""
    }
    
    func keyId() -> String {
        return name
    }
    
    static func ==(left: Item, right: Item) -> Bool {
        return left.name == right.name
    }
}
