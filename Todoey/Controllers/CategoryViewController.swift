//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Tanin on 25/12/2017.
//  Copyright © 2017 landtanin. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.rowHeight = 80.0
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories"
        
        return cell
        
    }
    
    
    // MARK: - Data Manipulation Methods, save(), load(), CRUD
    func save(category: Category){
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
        
    }
    
    // loadCategories(<externalParam> <internalParam>: NSFetchRequest<TableName> = <defaultValue>)
    func loadCategories(){
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
        
    }
    
    // MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath){
        
        if let itemToDelete = self.categories?[indexPath.row]{

            do {

                try self.realm.write {

                    self.realm.delete(itemToDelete)

                }

            } catch {

                print("Error deleting category, \(error)")

            }

        }
        
    }
    
    // MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        // create action button
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            // what will happen once the user clicks the Add item
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            self.save(category: newCategory)
        }
        
        // create textfield
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - TableView Delegate Methods, what should happen when we click osn cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
        
    }
    
    
}


