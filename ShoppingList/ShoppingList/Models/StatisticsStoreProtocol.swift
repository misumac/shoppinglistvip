//
//  StatisticsStoreProtocol.swift
//  ShoppingList
//
//  Created by Mihai on 3/20/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation

protocol StatisticsStoreProtocol {
    func suggestCategories(filter: String, completion: @escaping ([String]) -> Void)
    func suggestNames(filter: String, completion: @escaping ([String]) -> Void)
    func suggestItemCategory(itemName: String, completion: @escaping (String) -> Void)
    func itemWasUsed(itemName: String, itemCategory: String, previousCategory: String)
    func retrieveItems(forCategory category: String, dataHandler: @escaping (DataStoreEvent<Item>) -> Void)
    func countItemUsage(itemName name: String, completion: @escaping (Int) -> Void)
    func removeItem(item: Item)
}
