//
//  ShoppingListViewController.swift
//  ShoppingList
//
//  Created by Mihai on 3/11/17.
//  Copyright (c) 2017 Mihai. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol ShoppingListViewControllerInput {
    func displayDataEvent(viewmodel: ShoppingListScene.GetItems.ViewModel)
}

protocol ShoppingListViewControllerOutput {
    var dataSource: AnyTableSource<ListItem> { get }
    func getItems(request: ShoppingListScene.GetItems.Request)
    func toggleGrouping(request: ShoppingListScene.ToggleGrouping.Request)
    func toggleItem(request: ShoppingListScene.ToggleItem.Request)
    func selectItem(request: ShoppingListScene.SelectItem.Request)
    func deleteItem(request: ShoppingListScene.DeleteItem.Request)
}

class ShoppingListViewController: UIViewController, ShoppingListViewControllerInput {
    
    var output: ShoppingListViewControllerOutput!
    var router: ShoppingListRouter!
    
    //fileprivate var dataSource: AnyTableSource<ListItem>!
    
    @IBOutlet weak var groupButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: Object lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ShoppingListConfigurator.sharedInstance.configure(viewController: self)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupButton.setFAIcon(icon: .FATags, iconSize: 24)
        groupButton.target = self
        groupButton.action = #selector(groupButtonPressed(sender:))
        addButton.setFAIcon(icon: .FAPlus, iconSize: 24)
        addButton.target = self
        addButton.action = #selector(addButtonPressed(sender:))
        tableView.dataSource = self
        tableView.delegate = self
        output.getItems(request: ShoppingListScene.GetItems.Request())
    }
    
    // MARK: Event handling
    func groupButtonPressed(sender: UIBarButtonItem) {
        output.toggleGrouping(request: ShoppingListScene.ToggleGrouping.Request())
    }
    
    func addButtonPressed(sender: UIBarButtonItem) {
        output.selectItem(request: ShoppingListScene.SelectItem.Request(index: nil))
        router.navigateToAddItemScene()
    }
    
    // MARK: Display logic
    func displayDataEvent(viewmodel: ShoppingListScene.GetItems.ViewModel) {
        if viewmodel.dataEvent.isReload() {
            tableView.reloadData()
            return
        }
        tableView.beginUpdates()
        if viewmodel.dataEvent.rowDeletes.count > 0 {
            tableView.deleteRows(at: viewmodel.dataEvent.rowDeletes, with: .automatic)
        }
        if viewmodel.dataEvent.rowInserts.count > 0 {
            tableView.insertRows(at: viewmodel.dataEvent.rowInserts, with: .automatic)
        }
        if viewmodel.dataEvent.rowUpdates.count > 0 {
            tableView.reloadRows(at: viewmodel.dataEvent.rowUpdates, with: .automatic)
        }
        if viewmodel.dataEvent.sectionDeletes.count > 0 {
            tableView.deleteSections(IndexSet(viewmodel.dataEvent.sectionDeletes), with: .automatic)
        }
        if viewmodel.dataEvent.sectionChanges.count > 0 {
            tableView.reloadSections(IndexSet(viewmodel.dataEvent.sectionDeletes), with: .automatic)
        }
        if viewmodel.dataEvent.sectionInserts.count > 0 {
            tableView.insertSections(IndexSet(viewmodel.dataEvent.sectionInserts), with: .automatic)
        }
        tableView.endUpdates()
    }
    
    func displayGrouping(viewmodel: ShoppingListScene.ToggleGrouping.ViewModel) {
        tableView.reloadData()
    }
}

//This should be on configurator but for some reason storyboard doesn't detect ViewController's name if placed there
extension ShoppingListViewController: ShoppingListPresenterOutput {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router.passDataToNextScene(for: segue)
    }
}

extension ShoppingListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.dataSource.rows(inSection: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return output.dataSource.sectionsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = output.dataSource.item(forIndexPath: indexPath)
        //cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "\(item.quantity)"
        
        if item.handled {
            let text = NSMutableAttributedString(string: item.name, attributes: [NSStrikethroughStyleAttributeName:"1", NSForegroundColorAttributeName:UIColor.gray])
            cell.textLabel?.attributedText = text
        } else {
            let text = NSMutableAttributedString(string: item.name, attributes: [NSStrikethroughStyleAttributeName:"0", NSForegroundColorAttributeName:UIColor.black])
            cell.textLabel?.attributedText = text
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return output.dataSource.sectionTitle(section: section)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, index) in
            self.output.selectItem(request: ShoppingListScene.SelectItem.Request(index: index))
            self.router.navigateToAddItemScene()
            tableView.setEditing(false, animated: true)
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, index) in
            self.output.deleteItem(request: ShoppingListScene.DeleteItem.Request(item: self.output.dataSource.item(forIndexPath: index)))
            tableView.setEditing(false, animated: true)
        }
        return [editAction, deleteAction]
    }
}

extension ShoppingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.toggleItem(request: ShoppingListScene.ToggleItem.Request(item: output.dataSource.item(forIndexPath: indexPath)))
    }
}
