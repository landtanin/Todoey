//
//  Item.swift
//  Todoey
//
//  Created by Tanin on 26/12/2017.
//  Copyright © 2017 landtanin. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title : String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    // a reverse relationship to category parent-data class
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
