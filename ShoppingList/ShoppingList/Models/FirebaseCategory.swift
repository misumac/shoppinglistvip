//
//  FirebaseCategory.swift
//  ShoppingList
//
//  Created by Mihai on 3/18/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class FirebaseCategory {
    var key: String?
    var name: String
    var location: Int
    var items: [String]
    let ref: FIRDatabaseReference?
    
    init(name: String, location: Int, items: [String]) {
        self.name = name
        self.location = location
        self.items = items
        self.key = nil
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        name = snapshot.key
        self.ref = snapshot.ref
        let it = JSON(snapshot.value!)
        location = it["location"].int ?? 0
        items = [String]()
        if let jsItems = it["items"].dictionaryObject {
            for jsKey in jsItems.keys {
                items.append(jsKey)
            }
        }
    }
    
    init(withCategory cat: Category, ref: FIRDatabaseReference) {
        key = cat.name
        self.ref = ref
        name = cat.name
        items = cat.items
        location = cat.location
    }
    
    func update(withCategory cat: Category) {
        name = cat.name
        items = cat.items
        location = cat.location
    }
    
    func toCategory() -> Category {
        return Category(name: name, location: location, items: items, ref: ref)
    }
    
    func json() -> [String:Any] {
        var itemList = [[String:Any]]()
        for it in items {
            itemList.append([it : "true"])
        }
        return ["name" : name,
                "location" : location,
                "items" : itemList]
    }

}
