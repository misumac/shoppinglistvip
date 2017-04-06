//
//  CategoriesListViewController.swift
//  ShoppingList
//
//  Created by Mihai on 3/18/17.
//  Copyright (c) 2017 Mihai. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit
import Font_Awesome_Swift

protocol CategoriesListViewControllerInput: CategoriesListPresenterOutput {
}

protocol CategoriesListViewControllerOutput {
    var dataSource: AnyTableSource<Category> { get }
    func getCategories(request: CategoriesListScene.GetCategories.Request)
    func moveCategory(request: CategoriesListScene.MoveCategory.Request)
    func selectCategory(request: CategoriesListScene.SelectCategory.Request)
}

class CategoriesListViewController: UIViewController, CategoriesListViewControllerInput {
    
    var output: CategoriesListViewControllerOutput!
    var router: CategoriesListRouter!
    
    @IBOutlet weak var tableView: UITableView!
    // MARK: Object lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CategoriesListConfigurator.sharedInstance.configure(viewController: self)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let editButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(editButtonPressed(sender:)))
        editButton.setFAIcon(icon: .FAEdit, iconSize: 24)
        navigationItem.rightBarButtonItem = editButton
        tableView.dataSource = self
        tableView.delegate = self
        output.getCategories(request: CategoriesListScene.GetCategories.Request())
    }
    
    // MARK: Event handling
    func editButtonPressed(sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    // MARK: Display logic
    func displayDataEvent(viewModel: CategoriesListScene.GetCategories.ViewModel) {
        tableView.beginUpdates()
        if viewModel.dataEvent.rowDeletes.count > 0 {
            tableView.deleteRows(at: viewModel.dataEvent.rowDeletes, with: .automatic)
        }
        if viewModel.dataEvent.rowInserts.count > 0 {
            tableView.insertRows(at: viewModel.dataEvent.rowInserts, with: .automatic)
        }
        if viewModel.dataEvent.rowUpdates.count > 0 {
            tableView.reloadRows(at: viewModel.dataEvent.rowUpdates, with: .automatic)
        }
        if viewModel.dataEvent.sectionDeletes.count > 0 {
            tableView.deleteSections(IndexSet(viewModel.dataEvent.sectionDeletes), with: .automatic)
        }
        if viewModel.dataEvent.sectionChanges.count > 0 {
            tableView.reloadSections(IndexSet(viewModel.dataEvent.sectionDeletes), with: .automatic)
        }
        if viewModel.dataEvent.sectionInserts.count > 0 {
            tableView.insertSections(IndexSet(viewModel.dataEvent.sectionInserts), with: .automatic)
        }
        tableView.endUpdates()
    }
}

extension CategoriesListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.dataSource.rows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let cat = output.dataSource.item(forIndexPath: indexPath)
        cell.textLabel?.text = cat.name
        cell.detailTextLabel?.text = "Items: \(cat.items.count)"
        cell.showsReorderControl = true
        if cat.items.count == 0 {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        output.moveCategory(request: CategoriesListScene.MoveCategory.Request(fromIndex: sourceIndexPath, toIndex: destinationIndexPath))
    }
}

extension CategoriesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .none {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
        }
        output.selectCategory(request: CategoriesListScene.SelectCategory.Request(index: indexPath))
        router.navigateToItemsInCategoryScene()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//This should be on configurator but for some reason storyboard doesn't detect ViewController's name if placed there
extension CategoriesListViewController: CategoriesListPresenterOutput {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router.passDataToNextScene(for: segue)
    }
}