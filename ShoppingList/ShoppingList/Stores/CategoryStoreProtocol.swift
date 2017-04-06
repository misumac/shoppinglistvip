//
//  CategoryStoreProtocol.swift
//  ShoppingList
//
//  Created by Mihai on 3/18/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation

protocol CategoryStoreProtocol {
    func getItems(dataHandler: @escaping (DataStoreEvent<Category>) -> ())
    func getAllItems(dataHandler: @escaping (DataStoreEvent<Category>) -> ())
    func updateLocation(category cat: Category, location: Int)
}
