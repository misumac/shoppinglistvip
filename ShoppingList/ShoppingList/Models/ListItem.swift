//
//  ListItem.swift
//  ShoppingList
//
//  Created by Mihai on 3/12/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation

class ListItem : Sectionable {
    var name: String
    var category: String
    var quantity: Int
    var handled: Bool
    var ref: Any?
    
    init(name: String, category: String, quantity: Int, handled: Bool, ref: Any? = nil) {
        self.name = name
        self.category = category
        self.quantity = quantity
        self.handled = handled
        self.ref = ref
    }
    
    func sectionName() -> String {
    return category
    }
    
    func keyId() -> String {
        return name
    }
    
    static func ==(left: ListItem, right: ListItem) -> Bool {
        return left.name == right.name
    }
    
    static func contentMatches(left: ListItem, right: ListItem) -> Bool {
        return left.category == right.category && left.name == right.name && left.quantity == right.quantity && left.handled == right.handled
    }
}
