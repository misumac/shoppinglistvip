//
//  ListItemStoreProtocol.swift
//  ShoppingList
//
//  Created by Mihai on 3/12/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation

enum DataStoreEvent<T> {
    case initialData([T])
    case itemInserted(T)
    case itemDeleted(String)
    case itemUpdated(T)
}

protocol ListItemStoreProtocol {
    func getItems(dataHandler: @escaping (DataStoreEvent<ListItem>) -> ())
    func delete(item: ListItem)
    func changeState(forItem item: ListItem, newState state: Bool)
    func createUpdate(item: ListItem, completion: @escaping (Bool) -> ())
}
