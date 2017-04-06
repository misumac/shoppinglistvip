//
//  ItemDataSource.swift
//  ShoppingList
//
//  Created by Mihai on 2/12/17.
//  Copyright © 2017 Mihai. All rights reserved.
//

import Foundation

protocol Sectionable: Equatable {
    func sectionName() -> String
    func keyId() -> String
}



struct SectionData<T> {
    public var name: String
    public var items: [T]
    
    init(name: String, items: [T]) {
        self.name = name
        self.items = items
    }
}

protocol SectionComparer {
    func less(section s1: String, thanSection s2: String) -> Bool
}

class ItemDataSource<T:Sectionable>: TableSource {
    
    var items = [T]()
    var sectionsMap = [String : Int]()
    var sectionsList = [SectionData<T>]()
    var sectionComparerDelegate: SectionComparer?
    
    private var doSections = false
    
    func showsSections() -> Bool {
        return doSections
    }
    
    func reset() {
        items.removeAll()
        sectionsMap.removeAll()
        sectionsList.removeAll()
    }
    
    func switchSectionType() {
        if doSections {
            items.removeAll()
            for section in sectionsList {
                for item in section.items {
                    items.append(item)
                }
            }
            sectionsList.removeAll()
            sectionsMap.removeAll()
            doSections = false
        } else {
            sectionsMap.removeAll()
            sectionsList.removeAll()
            doSections = true
            for item in items {
                _ = add(item: item)
            }
            items.removeAll()
        }
    }
    
    func sectionsCount() -> Int {
        return doSections ? sectionsList.count : 1
    }
    
    func rows(inSection section: Int) -> Int {
        return doSections ? sectionsList[section].items.count : items.count
    }
    
    func item(forIndexPath index: IndexPath) -> T {
        return doSections ? sectionsList[index.section].items[index.row] : items[index.row]
    }
    
    func sectionTitle(section: Int) -> String? {
        return doSections ? sectionsList[section].name : nil
    }
    
    func add(item: T) -> ListEvent {
        if !doSections {
            var e = ListEvent()
            items.append(item)
            let idx = IndexPath(row: items.count - 1, section: 0)
            e.rowInserts.append(idx)
            return e
        }
        var r = 0
        var s = 0
        if let id = sectionsMap.index(forKey: item.sectionName()) {
            s = sectionsMap[item.sectionName()]!
            sectionsList[s].items.append(item)
            r = sectionsList[s].items.count - 1
        } else {
            if sectionComparerDelegate == nil {
                sectionsList.append(SectionData(name: item.sectionName(), items: [item]))
                s = sectionsList.count - 1
            } else {
                s = -1
                for i in 0..<sectionsList.count {
                    if sectionComparerDelegate!.less(section: item.sectionName(), thanSection: sectionsList[i].name) {
                        //insert here
                        s = i
                        sectionsList.insert(SectionData(name: item.sectionName(), items: [item]), at: i)
                        break
                    }
                }
                if s == -1 {
                    sectionsList.append(SectionData(name: item.sectionName(), items: [item]))
                    s = sectionsList.count - 1
                }
            }
            sectionsMap[item.sectionName()] = s
            r = 0
        }
        let idx = IndexPath(row:r, section:s)
        var e = ListEvent()
        if r == 0 {
            e.sectionInserts.append(s)
        } else {
            e.rowInserts.append(idx)
        }
        return e
    }
    
    func moveItem(from: IndexPath, to: IndexPath) {
        if !doSections {
            let item = items[from.row]
            items.remove(at: from.row)
            items.insert(item, at: to.row)
        }
    }
    
    func remove(key: String) -> ListEvent {
        var e = ListEvent()
        let idx = indexPath(forKey: key)!
        if !doSections {
            items.remove(at: idx.row)
            e.rowDeletes.append(idx)
            return e
        }
        
        if sectionsList[idx.section].items.count == 1 {
            let cat = sectionsList[idx.section].name
            sectionsList.remove(at: idx.section)
            sectionsMap.removeValue(forKey: cat)
            e.sectionDeletes.append(idx.section)
        } else {
            sectionsList[idx.section].items.remove(at: idx.row)
            e.rowDeletes.append(idx)
        }
        return e
    }
    
    func update(item: T) -> ListEvent {
        //let idx = keyMap[item.key!]!
        let idx = indexPath(forKey: item.keyId())!
        let oldItem = self.item(forIndexPath: idx)
        var e = ListEvent()
        if !doSections {
            e.rowUpdates.append(idx)
            items[idx.row] = item
            return e
        }
        
        if oldItem.sectionName() == item.sectionName() {
            sectionsList[idx.section].items[idx.row] = item
            e.rowUpdates.append(idx)
        } else {
            if sectionsMap.index(forKey: item.sectionName()) != nil { //move to existing section
                let newSection = sectionsMap[item.sectionName()]!
                sectionsList[newSection].items.append(item)
                let newIndex = IndexPath(row: sectionsList[newSection].items.count - 1, section: newSection)
                if removeItem(index: idx, category: oldItem.sectionName()) {
                    e.sectionDeletes.append(idx.section)
                } else {
                    e.rowDeletes.append(idx)
                }
                e.rowInserts.append(newIndex)
            } else { //new section
                if sectionsList[idx.section].items.count == 1 { //rename section
                    sectionsList[idx.section].name = item.sectionName()
                    sectionsList[idx.section].items[0] = item
                    sectionsMap.removeValue(forKey: oldItem.sectionName())
                    sectionsMap[item.sectionName()] = idx.section
                    e.sectionChanges.append(idx.section)
                } else { //insert section
                    let sectionRemoved = removeItem(index: idx, category: oldItem.sectionName())
                    let r = add(item: item)
                    e.sectionDeletes = r.sectionDeletes
                    e.sectionInserts = r.sectionInserts
                    e.rowInserts = r.rowInserts
                    if sectionRemoved {
                        e.sectionDeletes.append(idx.section)
                    } else {
                        e.rowDeletes.append(idx)
                    }
                }
            }
        }
        return e
    }
    
    private func removeItem(index: IndexPath, category: String) -> Bool {
        if !doSections {
            items.remove(at: index.row)
            return false
        }
        
        if sectionsList[index.section].items.count == 1 {
            sectionsList.remove(at: index.section)
            sectionsMap.removeValue(forKey: category)
            return true
        } else {
            sectionsList[index.section].items.remove(at: index.row)
            return false
        }
    }
    
    func indexPath(of item: T) -> IndexPath? {
        if !doSections {
            guard let r = items.index(of:item) else {
                return nil
            }
            return IndexPath(row: r, section: 0)
        }
        guard let s = sectionsMap[item.sectionName()] else {
            return nil
        }
        guard let r = sectionsList[s].items.index(of:item) else {
            return nil
        }
        return IndexPath(row: r, section: s)
    }
    
    func indexPath(forKey key: String) -> IndexPath? {
        if !doSections {
            if let index = items.index(where: { (it) -> Bool in
                return it.keyId() == key
            }) {
                return IndexPath(row: index, section: 0)
            }
            return nil
        }
        
        for s in 0...sectionsList.count - 1 {
            if let index = sectionsList[s].items.index(where: { (it) -> Bool in
                return it.keyId() == key
            }) {
                return IndexPath(row: index, section: s)
            }
        }
        return nil
    }
}
