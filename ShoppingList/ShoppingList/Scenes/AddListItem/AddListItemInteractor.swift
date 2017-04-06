//
//  AddListItemInteractor.swift
//  ShoppingList
//
//  Created by Mihai on 3/13/17.
//  Copyright (c) 2017 Mihai. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol AddListItemInteractorInput {
    func getItemOnLoad(request: AddListItemScene.GetItemOnLoad.Request)
    func saveItem(request: AddListItemScene.SaveItem.Request)
    func suggestNames(request: AddListItemScene.SuggestNames.Request)
    func suggestCategories(request: AddListItemScene.SuggestNames.Request)
    func getCategoryForItem(request: AddListItemScene.GetCategory.Request)
}

protocol AddListItemInteractorOutput {
    func presentItemOnLoad(response: AddListItemScene.GetItemOnLoad.Response)
    func presentItemSaved(response: AddListItemScene.SaveItem.Response)
    func presentNameSuggestions(response: AddListItemScene.SuggestNames.Response)
    func presentCategorySuggestions(response: AddListItemScene.SuggestNames.Response)
    func presentCategoryForItem(response: AddListItemScene.GetCategory.Response)
}

protocol AddListItemDataSource {
    
}

protocol AddListItemDataDestination {
    var item: ListItem? { get set }
}

class AddListItemInteractor: AddListItemInteractorInput, AddListItemDataSource, AddListItemDataDestination {
    
    var output: AddListItemInteractorOutput!
    var listItemStore: ListItemStoreProtocol!
    var statisticsStore: StatisticsStoreProtocol!
    var item: ListItem?
    // MARK: Business logic
    func getItemOnLoad(request: AddListItemScene.GetItemOnLoad.Request) {
        output.presentItemOnLoad(response: AddListItemScene.GetItemOnLoad.Response(item: item))
    }
    
    func saveItem(request: AddListItemScene.SaveItem.Request) {
        var response: AddListItemScene.SaveItem.Response.Result = .none
        if request.item.name.characters.count == 0 {
            response = .invalidName
        } else if request.item.quantity < 1 {
            response = .invalidQuantity
        }
        if response != .none {
            output.presentItemSaved(response: AddListItemScene.SaveItem.Response(result: response))
            return
        }
        let vmItem = request.item

        let newitem = ListItem(name: vmItem.name, category: vmItem.category, quantity: vmItem.quantity, handled: false, ref: item?.ref)
        listItemStore.createUpdate(item: newitem) {[weak self] (success) in
            if success {
                if let weakself = self {
                    weakself.statisticsStore.itemWasUsed(itemName: vmItem.name, itemCategory: vmItem.category, previousCategory: weakself.item?.category ?? "")
                    weakself.output.presentItemSaved(response: AddListItemScene.SaveItem.Response(result: .saved))
                }
            } else {
                self?.output.presentItemSaved(response: AddListItemScene.SaveItem.Response(result: .saveError))
            }
        }
    }
    
    func suggestNames(request: AddListItemScene.SuggestNames.Request) {
        statisticsStore.suggestNames(filter: request.filter) {[weak self] (names) in
            self?.output.presentNameSuggestions(response: AddListItemScene.SuggestNames.Response(names: names))
        }
    }
    
    func suggestCategories(request: AddListItemScene.SuggestNames.Request) {
        statisticsStore.suggestCategories(filter: request.filter) {[weak self] (names) in
            self?.output.presentCategorySuggestions(response: AddListItemScene.SuggestNames.Response(names: names))
        }
    }

    func getCategoryForItem(request: AddListItemScene.GetCategory.Request) {
        statisticsStore.suggestItemCategory(itemName: request.name) {[weak self] (category) in
            self?.output.presentCategoryForItem(response: AddListItemScene.GetCategory.Response(category: category))
        }
    }
}