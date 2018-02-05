//
//  ViewController.swift
//  Todoey
//
//  Created by Tanin on 19/12/2017.
//  Copyright © 2017 landtanin. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet var searchBar: UISearchBar!
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    //    let defaults = UserDefaults.standard
    
    // onCreate in Android
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
    }
    
    // onStart in Android, this is the point where we can make sure that this class is alreday stack on the navigation view (navigation view is ready to be called and hence won't return nil)
    override func viewWillAppear(_ animated: Bool) {
        
        // make navBar title consistent to the category
        title = selectedCategory?.name
        
        // change the color of both nav and status bars
        guard let colourHex = selectedCategory?.color else {fatalError()}
        
        updateNavBar(withHexCode: colourHex)
        
    }
    
    // onStop, reset the navBar colors
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "53C187")
        
    }
    
    // MARK: - Nav Bar Setup Methods
    func updateNavBar(withHexCode colourHexCode: String){
        // make sure the navigationBar is exist
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        
        
        // change items in nav area colors
        guard let navBarColour = UIColor(hexString: colourHexCode) else {fatalError()}
        
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        
        searchBar.barTintColor = navBarColour
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            
            cell.textLabel?.text = item.title
            
            let catColorStr = item.parentCategory.first?.color
            let catColor = HexColor(catColorStr!)
            
            if let color = catColor?.darken(byPercentage:
                CGFloat(indexPath.row)/CGFloat(todoItems!.count)
                ){
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                
            }
            
            // Ternary operator
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
        
    }
    
    
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print(itemArray[indexPath.row])
        
        if let item = todoItems?[indexPath.row]{
            
            do {
                
                // update to Realm (crUd)
                try realm.write {
                    
                    item.done = !item.done
                    
                }
                
            } catch {
                
                print("Error saving done status, \(error)")
                
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        // create action button
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // what will happen once the user clicks the Add item
            if let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        let newItem = Item()
                        let newDate = Date()
                        newItem.title = textField.text!
                        newItem.dateCreated = newDate
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving context \(error)")
                }
                
            }
            
            self.tableView.reloadData()
            
        }
        
        // create textfield
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // loadItems(<externalParam> <internalParam>: NSFetchRequest<Item> = <defaultVar>)
    func loadItems(){
        
        // Read from Realm (cRud)
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    // MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            
            do {
                
                // update to Realm (crUd)
                try self.realm.write {
                    
                    self.realm.delete(item)
                    
                }
                
            } catch {
                
                print("Error deleting todo items, \(error)")
                
            }
        }
        
    }
}

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
        
    }
    
}

