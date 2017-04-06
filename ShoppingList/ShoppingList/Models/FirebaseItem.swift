//
//  FirebaseItem.swift
//  ShoppingList
//
//  Created by Mihai on 3/25/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class FirebaseItem {
    var name: String
    var category: String
    var lastUsed: Date?
    var ref: FIRDatabaseReference?
    
    required init(name: String, lastUsed: Date?, category: String) {
        self.name = name
        self.lastUsed = lastUsed
        self.category = category
    }
    
    convenience init(name: String, lastUsed: Date?, category: String, ref: FIRDatabaseReference) {
        self.init(name: name, lastUsed: lastUsed, category: category)
        self.ref = ref
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.name = snapshot.key
        self.ref = snapshot.ref
        let it = JSON(snapshot.value!)
        category = it["category"].stringValue
        if let date = it["lastUsed"].string {
            self.lastUsed = dateFormatter().date(from: date)
        }
    }
    
    func json() -> [String:Any] {
        var dict = [String:Any]()
        dict["category"] = category
        if let date = lastUsed {
            dict["lastUsed"] = dateFormatter().string(from: date)
        }
        return dict
    }
    
    func toItem() -> Item {
        return Item(name: name, lastUsed: lastUsed, category: category, ref: ref)
    }
    
    func dateFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }
}
