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
    @objc dynamic var name : String = ""
    
    // relationship to List sub-data class
    let items = List<Item>()
}
