//
//  AddListItemConfigurator.swift
//  ShoppingList
//
//  Created by Mihai on 3/13/17.
//  Copyright (c) 2017 Mihai. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

// MARK: Connect View, Interactor, and Presenter

extension AddListItemInteractor: AddListItemViewControllerOutput, AddListItemRouterDataSource, AddListItemRouterDataDestination {
}

extension AddListItemPresenter: AddListItemInteractorOutput {
}

class AddListItemConfigurator {
    // MARK: Object lifecycle
    
    static let sharedInstance = AddListItemConfigurator()
    
    private init() {}
    
    // MARK: Configuration
    
    func configure(viewController: AddListItemViewController) {
        
        let presenter = AddListItemPresenter()
        presenter.output = viewController
        
        let interactor = AddListItemInteractor()
        interactor.output = presenter
        interactor.listItemStore = FirebaseListItemStore()
        interactor.statisticsStore = FirebaseStatisticsStore()
        
        let router = AddListItemRouter(viewController:viewController, dataSource:interactor, dataDestination:interactor)
        
        viewController.output = interactor
        viewController.router = router
    }
}
