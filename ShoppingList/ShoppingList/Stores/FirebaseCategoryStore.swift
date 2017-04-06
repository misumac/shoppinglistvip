//
//  FirebaseCategoryStore.swift
//  ShoppingList
//
//  Created by Mihai on 3/18/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseCategoryStore: CategoryStoreProtocol {
    lazy var ref = FIRDatabase.database().reference(withPath: "categories")
    var observers = [UInt]()
    
    init() {
        
    }
    
    deinit {
        cleanupObservers()
    }
    
    func getItems(dataHandler: @escaping (DataStoreEvent<Category>) -> ()) {
        cleanupObservers()
        let query = ref.queryOrdered(byChild: "location")
        observers.append(query.observe(.childAdded, with: {(snapshot) in
            let item = FirebaseCategory(snapshot: snapshot)
            dataHandler(DataStoreEvent<Category>.itemInserted(item.toCategory()))
        }))
        observers.append(query.observe(.childRemoved, with: { (snapshot) in
            let item = FirebaseCategory(snapshot: snapshot)
            dataHandler(DataStoreEvent<Category>.itemDeleted(item.name))
        }))
        observers.append(query.observe(.childChanged, with: { (snapshot) in
            let item = FirebaseCategory(snapshot: snapshot)
            dataHandler(DataStoreEvent<Category>.itemUpdated(item.toCategory()))
        }))
    }
    
    func getAllItems(dataHandler: @escaping (DataStoreEvent<Category>) -> ()) {
        let query = ref.queryOrdered(byChild: "location")
        query.observe(.value, with: { (snapshot) in
            var items = [Category]()
            for i in snapshot.children {
                let item = FirebaseCategory(snapshot: i as! FIRDataSnapshot)
                items.append(item.toCategory())
            }
            dataHandler(DataStoreEvent<Category>.initialData(items))
        })
    }
    
    func updateLocation(category cat: Category, location: Int) {
        if let ref = cat.ref as? FIRDatabaseReference {
            ref.updateChildValues(["location" : location])
        }
    }
    
    private func cleanupObservers() {
        for handle in observers {
            ref.removeObserver(withHandle: handle)
        }
        observers.removeAll()
    }
}
