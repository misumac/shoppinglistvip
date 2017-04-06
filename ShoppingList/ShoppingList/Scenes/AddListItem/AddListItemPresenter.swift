//
//  AddListItemPresenter.swift
//  ShoppingList
//
//  Created by Mihai on 3/13/17.
//  Copyright (c) 2017 Mihai. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol AddListItemPresenterInput {
    func presentItemOnLoad(response: AddListItemScene.GetItemOnLoad.Response)
    func presentItemSaved(response: AddListItemScene.SaveItem.Response)
    func presentNameSuggestions(response: AddListItemScene.SuggestNames.Response)
    func presentCategorySuggestions(response: AddListItemScene.SuggestNames.Response)
    func presentCategoryForItem(response: AddListItemScene.GetCategory.Response)
}

protocol AddListItemPresenterOutput: class {
    func displayItem(viewModel: AddListItemScene.GetItemOnLoad.ViewModel)
    func displayItemSaved(viewModel: AddListItemScene.SaveItem.ViewModel)
    func displayNameSuggestions(viewModel: AddListItemScene.SuggestNames.ViewModel)
    func displayCategorySuggestions(viewModel: AddListItemScene.SuggestNames.ViewModel)
    func displayCategoryForItem(viewModel: AddListItemScene.GetCategory.ViewModel)
}

class AddListItemPresenter: AddListItemPresenterInput {
    
    weak var output: AddListItemPresenterOutput!
    
    // MARK: Presentation logic
    func presentItemOnLoad(response: AddListItemScene.GetItemOnLoad.Response) {
        if let item = response.item {
            let vmItem = AddListItemScene.ListItemVM(name: item.name, category: item.category, quantity: item.quantity)
            output.displayItem(viewModel: AddListItemScene.GetItemOnLoad.ViewModel(item: vmItem, navTitle: "Edit item"))
        } else {
            output.displayItem(viewModel: AddListItemScene.GetItemOnLoad.ViewModel(item: AddListItemScene.ListItemVM(name: "", category: "", quantity: 1), navTitle: "Add item"))
        }
    }
    
    func presentItemSaved(response: AddListItemScene.SaveItem.Response) {
        DispatchQueue.main.async {[weak self] in
            var msg: String
            switch response.result {
            case .invalidName:
                msg = "Invalid name"
            case .invalidQuantity:
                msg = "Invalid quantity"
            case .none:
                msg = "No error"
            case .saved:
                msg = "Saved successfully"
            case .saveError:
                msg = "DB save error"
            }
            self?.output.displayItemSaved(viewModel: AddListItemScene.SaveItem.ViewModel(success: (response.result == .saved), errorMessage: msg))
        }
    }
    
    func presentNameSuggestions(response: AddListItemScene.SuggestNames.Response) {
        DispatchQueue.main.async {[weak self] in
            self?.output.displayNameSuggestions(viewModel: AddListItemScene.SuggestNames.ViewModel(names: response.names))
        }
    }
    
    func presentCategorySuggestions(response: AddListItemScene.SuggestNames.Response) {
        DispatchQueue.main.async {[weak self] in
            self?.output.displayCategorySuggestions(viewModel: AddListItemScene.SuggestNames.ViewModel(names: response.names))
        }
    }
    
    func presentCategoryForItem(response: AddListItemScene.GetCategory.Response) {
        DispatchQueue.main.async {[weak self] in
            self?.output.displayCategoryForItem(viewModel: AddListItemScene.GetCategory.ViewModel(category: response.category))
        }
    }
}