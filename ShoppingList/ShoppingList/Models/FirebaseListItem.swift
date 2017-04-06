//
//  FirebaseListItem.swift
//  ShoppingList
//
//  Created by Mihai on 3/12/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class FirebaseListItem {
    var key: String?
    var name: String
    var quantity: Int
    var category: String
    var state: Bool
    let ref: FIRDatabaseReference?
    
    init(name: String, quantity: Int, category: String, state: Bool) {
        self.key = nil
        self.name = name
        self.quantity = quantity
        self.category = category
        self.state = state
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        let it = JSON(snapshot.value!)
        self.name = it["name"].stringValue
        self.quantity = it["quantity"].intValue
        self.category = it["category"].stringValue
        self.state = it["completed"].boolValue
        self.ref = snapshot.ref
    }
    
    init(withListItem item: ListItem, key: String, ref: FIRDatabaseReference) {
        self.key = key
        self.ref = ref
        name = item.name
        category = item.category
        quantity = item.quantity
        state = item.handled
    }
    
    func update(withListItem item: ListItem) {
        name = item.name
        category = item.category
        quantity = item.quantity
        state = item.handled
    }
    
    func toListItem() -> ListItem {
        return ListItem(name: name, category: category, quantity: quantity, handled: state, ref: ref)
    }
    
    func json() -> [String:Any] {
        return ["name" : name,
                "quantity" : quantity,
                "category" : category,
                "completed" : state]
    }
}
