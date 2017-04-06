//
//  TableSource.swift
//  ShoppingList
//
//  Created by Mihai on 3/12/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation

struct ListEvent {
    var sectionChanges = [Int]()
    var sectionInserts = [Int]()
    var sectionDeletes = [Int]()
    
    var rowInserts = [IndexPath]()
    var rowUpdates = [IndexPath]()
    var rowDeletes = [IndexPath]()
    var rowMoves = [(IndexPath, IndexPath)]()
    
    func isReload() -> Bool {
        return sectionInserts.count == 0 && sectionChanges.count == 0 && sectionDeletes.count == 0 && rowInserts.count == 0 && rowMoves.count == 0 && rowDeletes.count == 0 && rowUpdates.count == 0
    }
}

protocol TableSource {
    associatedtype ItemType
    
    func sectionsCount() -> Int
    func rows(inSection section: Int) -> Int
    func item(forIndexPath index: IndexPath) -> ItemType
    func sectionTitle(section: Int) -> String? 
    
}

class AnyTableSource<T>: TableSource {
    
    private let _sectionsCount: () -> Int
    private let _rows: (Int) -> Int
    private let _item: (IndexPath) -> T
    private let _sectionTitle: (Int) -> String?
    
    required init<U: TableSource>(tableSource: U) where U.ItemType == T {
        _sectionsCount = tableSource.sectionsCount
        _rows = tableSource.rows
        _item = tableSource.item
        _sectionTitle = tableSource.sectionTitle
    }
    
    func sectionsCount() -> Int {
        return _sectionsCount()
    }

    func rows(inSection section: Int) -> Int {
        return _rows(section)
    }
    
    func item(forIndexPath index: IndexPath) -> T {
        return _item(index)
    }
    
    func sectionTitle(section: Int) -> String? {
        return _sectionTitle(section)
    }
    
}
