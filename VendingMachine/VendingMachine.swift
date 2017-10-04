//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Mac on 05/10/2017.
//  Copyright © 2017 SmartSoft. All rights reserved.
//

import Foundation

//Model
//enum to hold items
enum VendingSelection {
    case soda
    case dietSoda
    case chips
    case cookie
    case sandwich
    case wrap
    case candyBar
    case popTart
    case water
    case fruitJuice
    case sportsDrink
    case gum
}

protocol VendingItem {
    var price: Double { get }
    var quantity: Int { get set }
}

protocol VendingMachine {
    var selection: [VendingSelection] { get }
    var inventory: [VendingSelection: VendingItem] { get set }
    var amountDeposited: Double { get set }
    
    init(inventory: [VendingSelection: VendingItem])
    func vend(_ quantity: Int, _ selection: VendingSelection) throws
    func deposit(_ amount: Double)
    
}

struct Item: VendingItem {
    let price: Double
    var quantity: Int
}

//Error type to model any errorcould arise
enum IventoryError: Error {
    case invalidResource
    case conversionFailure
}

//Data Property list from the local file
class PlistConverter {
    static func Dictionary(FromFile name: String, ofType type: String) throws -> [String: AnyObject]{
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw IventoryError.invalidResource
        }
        
        //casting as? giving any object to our dict
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            throw IventoryError.conversionFailure
        }
        
        return dictionary
    }
}

//create an iventory
class IventoryUnarchiver {
    static func vendingIventory(fromDictionary dictionary: [String: AnyObject]) -> [VendingSelection: VendingItem] {
        var inventory: [VendingSelection: VendingItem] = [:]
        
        for (key, value) in dictionary {
            if let itemDictionary = value as? [String: Any], let price = itemDictionary["price"] as? Double, let quantity = itemDictionary["quantity"] as? Int {
                
                let item = Item(price: price, quantity: quantity)
            }
        }
        return inventory
    }
}

class FoodVendingMachine: VendingMachine {
    let selection: [VendingSelection] = [.soda, .dietSoda, .chips, .cookie, .fruitJuice, .gum, .popTart, .sandwich, .candyBar, .sportsDrink, .water, .wrap]
    
    var inventory: [VendingSelection : VendingItem]
    var amountDeposited: Double = 10.0
    
    required init(inventory: [VendingSelection : VendingItem]) {
        self.inventory = inventory
    }
    
    func vend(_ quantity: Int, _ selection: VendingSelection) throws {
        
    }
    
    func deposit(_ amount: Double) {
        
    }
}














