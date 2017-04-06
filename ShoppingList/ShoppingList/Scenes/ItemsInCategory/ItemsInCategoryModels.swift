//
//  ItemsInCategoryModels.swift
//  ShoppingList
//
//  Created by Mihai on 3/25/17.
//  Copyright (c) 2017 Mihai. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//
//  Type "usecase" for some magic!

import UIKit



struct ItemsInCategoryScene {
    struct GetItems {
        
        struct Request {
            
        }
        
        struct Response {
            var event: ListEvent
        }
        
        struct ViewModel {
            var event: ListEvent
        }
    }
    struct DeteleItem {
        
        struct Request {
            var index: IndexPath
        }
        
        struct Response {
            var success: Bool
        }
        
        struct ViewModel {
            
        }
    }
}
