//
//  Category.swift
//  Todoey
//
//  Created by Tanin on 26/12/2017.
//  Copyright © 2017 landtanin. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    
    // dynamic: we can monitor for changing while the app is running
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    
    // relationship to List sub-data class
    let items = List<Item>()
}
