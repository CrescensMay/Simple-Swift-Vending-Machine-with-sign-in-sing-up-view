//
//  ViewController.swift
//  VendingMachine
//
//  Created by Mac on 5/10/17.
//  Copyright © 2017 SmartSoft All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "vendingItem"
fileprivate let screenWidth = UIScreen.main.bounds.width

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    let vendingMachine: VendingMachine
    var currentSelection: VendingSelection?
    
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let dictionary = try PlistConverter.Dictionary(FromFile: "VendingInventory", ofType: "plist")
            let inventory = try IventoryUnarchiver.vendingIventory(fromDictionary: dictionary)
            self.vendingMachine = FoodVendingMachine(inventory: inventory)
            
        }catch let error {
            fatalError("\(error)")
        }
        //complete the initializer
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCollectionViewCells()
        
        updateDisplayWith(balance: vendingMachine.amountDeposited, totalPrice: 0, itemPrice: 0, itemQuatity: 1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup

    func setupCollectionViewCells() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        let padding: CGFloat = 10
        let itemWidth = screenWidth/3 - padding
        let itemHeight = screenWidth/3 - padding
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - Vending Machine
    
    @IBAction func purchase() {
        if let currentSelection = currentSelection {
            do {
                try vendingMachine.vend(selection: currentSelection, quantity: Int(quantityStepper.value))
                updateDisplayWith(balance: vendingMachine.amountDeposited, totalPrice: 0.0, itemPrice: 0, itemQuatity: 1)
                
            } catch VendingMachineError.outOfStock {
               showAlertWith(title: "Out Of Stock", message: "This item is unavailable, please make another selection")
            } catch VendingMachineError.invalidSelection {
                showAlertWith(title: "Invalid Selection", message: "Please make another selection")
            } catch VendingMachineError.insufficientFunds(let required) {
                let message = "You need $\(required) to complete the transaction"
                showAlertWith(title: "Insufficient Funds", message: message)
            } catch let error {
                fatalError("\(error)")
            }
            
            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                collectionView.deselectItem(at: indexPath, animated: true)
                updateCell(having: indexPath, selected: false)
            }
        } else {
            // FIXME: Alert user to no selection
        }
    }
    
    func updateDisplayWith(balance: Double? = nil, totalPrice: Double? = nil, itemPrice: Double? = nil, itemQuatity: Int? = nil) {
        
        if let balanceValue = balance {
            balanceLabel.text = "$\(balanceValue)"
        }
        
        if let totalValue = totalPrice {
            totalLabel.text = "$\(totalValue)"
        }
        
        if let totalPrice = itemPrice {
            priceLabel.text = "$\(totalPrice)"
        }
        
        if let quantityValue = itemQuatity {
            quantityLabel.text = "\(quantityValue)"
        }
    }
    
    func updateTotalPrice(for item: VendingItem) {
        let totalPrice = item.price * quantityStepper.value
        updateDisplayWith(totalPrice: totalPrice)
    }
    @IBAction func updateQuantity(_ sender: UIStepper) {
        let quantity = Int(quantityStepper.value)
        updateDisplayWith(itemQuatity: quantity)
        
        if let currentSelection = currentSelection, let item = vendingMachine.item(forSelection: currentSelection) {
            updateTotalPrice(for: item)
        }
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let actoin = UIAlertAction(title: "OK", style: .default, handler: dismissAlert)
        alertController.addAction(actoin)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func dismissAlert(sender: UIAlertAction) -> Void {
        updateDisplayWith(balance: 0, totalPrice: 0, itemPrice: 0, itemQuatity: 1)
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? VendingItemCell else { fatalError() }
        
        //get item been displayed
        let item = vendingMachine.selection[indexPath.row]
        cell.iconView.image = item.icon()
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
        
        quantityStepper.value = 1
    
        updateDisplayWith(totalPrice: 0, itemQuatity: 1)
        totalLabel.text = "$0.00"
        print(vendingMachine.selection[indexPath.row])
        //Updating the price and total price on the view
        currentSelection = vendingMachine.selection[indexPath.row]
        if let currentSelection = currentSelection, let item = vendingMachine.item(forSelection: currentSelection) {
            
            let itemPrice = item.price
            let totalValue = item.price * quantityStepper.value
            updateDisplayWith(totalPrice: totalValue, itemPrice: itemPrice)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func updateCell(having indexPath: IndexPath, selected: Bool) {
        
        let selectedBackgroundColor = UIColor(red: 41/255.0, green: 211/255.0, blue: 241/255.0, alpha: 1.0)
        let defaultBackgroundColor = UIColor(red: 27/255.0, green: 32/255.0, blue: 36/255.0, alpha: 1.0)
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = selected ? selectedBackgroundColor : defaultBackgroundColor
        }
    }
    
    
}

