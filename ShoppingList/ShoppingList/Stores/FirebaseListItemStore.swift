//
//  FirebaseListItemStore.swift
//  ShoppingList
//
//  Created by Mihai on 3/12/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseListItemStore: ListItemStoreProtocol {
    lazy var ref = FIRDatabase.database().reference(withPath: "lists/shopping/items")
    var observers = [UInt]()
    init() {
        
    }
    
    deinit {
        cleanupObservers()
    }
    
    func getItems(dataHandler: @escaping (DataStoreEvent<ListItem>) -> ()) {
        let query = ref.queryOrdered(byChild: "category")
        cleanupObservers()
        /*observers.append(query.observe(.value, with: { (snaphot) in
            var items = [ListItem]()
            for i in snaphot.children {
                items.append(FirebaseListItem(snapshot:i as! FIRDataSnapshot).toListItem())
            }
            dataHandler(DataStoreEvent<ListItem>.initialData(items))
        }))*/
        observers.append(query.observe(.childAdded, with: {(snapshot) in
            let item = FirebaseListItem(snapshot: snapshot)
            dataHandler(DataStoreEvent<ListItem>.itemInserted(item.toListItem()))
        }))
        observers.append(query.observe(.childRemoved, with: { (snapshot) in
            let item = FirebaseListItem(snapshot: snapshot)
            dataHandler(DataStoreEvent<ListItem>.itemDeleted(item.name))
        }))
        observers.append(query.observe(.childChanged, with: { (snapshot) in
            let item = FirebaseListItem(snapshot: snapshot)
            dataHandler(DataStoreEvent<ListItem>.itemUpdated(item.toListItem()))
        }))
    }
    
    func delete(item: ListItem) {
        if let childRef = item.ref as? FIRDatabaseReference {
            childRef.removeValue()
        }
        /*let query = ref.queryOrdered(byChild: "name").queryEqual(toValue: item.name)
        query.observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            let fItem = FirebaseListItem(snapshot: snapshot)
            self?.ref.child(fItem.key!).removeValue()
        })*/
    }
    
    func changeState(forItem item: ListItem, newState state: Bool) {
        let ref = FIRDatabase.database().reference(withPath: "lists/shopping/items")
        firebaseItem(withName: item.name, ref: ref) { (fItem) in
            if let fItem = fItem {
                let itemRef = ref.child("\(fItem.key!)")
                itemRef.updateChildValues(["completed":(state ? "true" : "false")])
            }
        }
    }
    
    func createUpdate(item: ListItem, completion: @escaping (Bool) -> ()) {
        /*var childRef: FIRDatabaseReference
        if let existingRef = item.ref as? FIRDatabaseReference {
            childRef = existingRef
            
        } else {
            childRef = self.ref.childByAutoId()
        }
        let fItem = FirebaseListItem(withListItem: item, key: childRef.key, ref: childRef)
        childRef.setValue(fItem.json(), withCompletionBlock: { (error, dbRef) in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        })*/
        //var childref: FIRDatabaseReference
        firebaseItem(withName: item.name, ref: ref) {[unowned self] (firebaseItem) in
            var childref: FIRDatabaseReference
            var fItem = firebaseItem
            if fItem != nil { //update
                childref = self.ref.child(fItem!.key!)
                fItem!.update(withListItem: item)
            } else { //create
                childref = self.ref.childByAutoId()
                fItem = FirebaseListItem(withListItem: item, key: childref.key, ref: childref)
            }
            childref.setValue(fItem!.json(), withCompletionBlock: { (error, dbRef) in
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
    
    func firebaseItem(withName name: String, ref: FIRDatabaseReference, completion: @escaping (FirebaseListItem?) -> ()) {
        let query = ref.queryOrdered(byChild: "name").queryEqual(toValue: name)
        query.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                let item = FirebaseListItem(snapshot: snapshot.children.nextObject() as! FIRDataSnapshot)
                completion(item)
            } else {
                completion(nil)
            }
        })
    }
    
    private func cleanupObservers() {
        for handle in observers {
            ref.removeObserver(withHandle: handle)
        }
        observers.removeAll()
    }
    
}
