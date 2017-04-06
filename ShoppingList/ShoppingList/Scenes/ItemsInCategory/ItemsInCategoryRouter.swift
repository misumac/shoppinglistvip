//
//  ItemsInCategoryRouter.swift
//  ShoppingList
//
//  Created by Mihai on 3/25/17.
//  Copyright (c) 2017 Mihai. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol ItemsInCategoryRouterInput {
    
}

protocol ItemsInCategoryRouterDataSource:class {
    
}

protocol ItemsInCategoryRouterDataDestination:class {
    var selectedCategory: Category? { get set }
}

class ItemsInCategoryRouter: ItemsInCategoryRouterInput {
    
    weak var viewController:ItemsInCategoryViewController!
    weak private var dataSource:ItemsInCategoryRouterDataSource!
    weak var dataDestination:ItemsInCategoryRouterDataDestination!
    
    init(viewController:ItemsInCategoryViewController, dataSource:ItemsInCategoryRouterDataSource, dataDestination:ItemsInCategoryRouterDataDestination) {
        self.viewController = viewController
        self.dataSource = dataSource
        self.dataDestination = dataDestination
    }
    
    // MARK: Navigation
    
    // MARK: Communication
    
    func passDataToNextScene(for segue: UIStoryboardSegue) {
        // NOTE: Teach the router which scenes it can communicate with
        
    }
}