//
//  FirebaseStatisticsStore.swift
//  ShoppingList
//
//  Created by Mihai on 3/20/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class FirebaseStatisticsStore: StatisticsStoreProtocol {
    func suggestNames(filter: String, completion: @escaping ([String]) -> Void) {
        let ref = FIRDatabase.database().reference(withPath: "items")
        ref.queryOrderedByKey().queryStarting(atValue: filter).observeSingleEvent(of: .value, with: { (snapshot) in
            var items = [String]()
            for child in snapshot.children {
                let key = (child as! FIRDataSnapshot).key
                items.append(key)
            }
            completion(items)
        })
    }
    
    func suggestCategories(filter: String, completion: @escaping ([String]) -> Void) {
        let ref = FIRDatabase.database().reference(withPath: "categories")
        ref.queryOrderedByKey().queryStarting(atValue: filter).observeSingleEvent(of: .value, with: { (snapshot) in
            var items = [String]()
            for child in snapshot.children {
                let key = (child as! FIRDataSnapshot).key
                items.append(key)
            }
            completion(items)
        })
    }
    
    func suggestItemCategory(itemName: String, completion: @escaping (String) -> Void) {
        let ref = FIRDatabase.database().reference(withPath: "items/\(itemName)")
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let v = snapshot.value {
                let js = JSON(v)
                completion(js["category"].stringValue)
            } else {
                completion("")
            }
        })
    }
    
    func itemWasUsed(itemName: String, itemCategory: String, previousCategory: String) {
        let href = FIRDatabase.database().reference()
        let hintref = href.child("items/\(itemName)")
        hintref.setValue(["category":itemCategory,"lastUsed":dateFormatter().string(from: Date(timeIntervalSinceNow: 0))])
        let catref = href.child("categories/\(itemCategory)/items")
        catref.updateChildValues([itemName:"true"])
        if previousCategory.characters.count > 0 && previousCategory != itemCategory {
            let oldCatRef = href.child("categories/\(previousCategory)/items/\(itemName)")
            oldCatRef.removeValue()
        }
    }
    
    func removeItem(item: Item) {
        if let itemRef = item.ref as? FIRDatabaseReference {
            itemRef.removeValue()
            let catrefs = FIRDatabase.database().reference(withPath: "categories")
            let usageRef = catrefs.child("\(item.category)/items/\(item.name)")
            usageRef.removeValue()
        }
    }
    
    func retrieveItems(forCategory category: String, dataHandler: @escaping (DataStoreEvent<Item>) -> Void) {
        let ref = FIRDatabase.database().reference(withPath: "items")
        let query = ref.queryOrdered(byChild: "category").queryEqual(toValue: category)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            var items = [Item]()
            for child in snapshot.children {
                items.append(FirebaseItem(snapshot: child as! FIRDataSnapshot).toItem())
            }
            dataHandler(DataStoreEvent<Item>.initialData(items))
        })
    }
    
    func countItemUsage(itemName name: String, completion: @escaping (Int) -> Void) {
        let ref = FIRDatabase.database().reference(withPath: "lists/shopping/items")
        let query = ref.queryOrdered(byChild: "name").queryEqual(toValue: name)
        query.observeSingleEvent(of: .value, with: {(snapshot) in
            let count = snapshot.childrenCount
            completion(Int(count))
        })
    }
    
    func dateFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }
}
