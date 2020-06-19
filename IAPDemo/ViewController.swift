//
//  ViewController.swift
//  ApplePayDemo
//
//  Created by Aryan Sharma on 17/06/20.
//  Copyright © 2020 Iimjobs. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {

    @IBOutlet weak var subscribeBtn: UIButton!
    
    var proSubscriptionProduct: SKProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register delegates
        StoreManager.shared.delegate = self
        StoreObserver.shared.delegate = self
        
        disableBtn()
        
        // Request to get available product ids from app store.
        StoreManager.shared.startProductRequest()
    }
    
    @IBAction func subscribeAction(_ sender: Any) {
        if let product = proSubscriptionProduct {
            print("print - Buy product: \(product.localizedTitle)")
            StoreObserver.shared.buy(product)
        } else {
            print("print - \(Messages.unknownPaymentTransaction)")
        }
    }
    
    func enableBtn() {
        subscribeBtn.isEnabled = true
        subscribeBtn.alpha = 1.0
    }
    
    func disableBtn() {
        subscribeBtn.isEnabled = false
        subscribeBtn.alpha = 0.5
    }
    
    // MARK: - Display Alert
    
    /// Creates and displays an alert.
    fileprivate func alert(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString(Messages.okButton, comment: Messages.emptyString),
                                   style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - StoreObserverDelegate

extension ViewController: StoreObserverDelegate {
    func storeObserverPurchased(_ transaction: SKPaymentTransaction, completionHandler: @escaping (Bool) -> Void) {
        // #### Provide content to the user. ####
        disableBtn()
        subscribeBtn.setTitle("You are now a Pro Member.", for: .normal)
        completionHandler(true)
    }
    
    func storeObserverDidReceiveMessage(_ message: String) {
        alert(with: Messages.purchaseStatus, message: message)
    }
}

// MARK: - StoreManagerDelegate

extension ViewController: StoreManagerDelegate {
    func storeManagerDidReceiveProduct(_ product: SKProduct) {
        // Enable button as the product has been received from app store.
        enableBtn()
        // Save the product.
        proSubscriptionProduct = product
        
        // Use price of the product as received from the app store.
        if let regularPrice = product.regularPrice {
            subscribeBtn.setTitle("Buy for \(regularPrice)", for: .normal)
        } else {
            subscribeBtn.setTitle("Buy for Rs. \(product.price)", for: .normal)
        }
    }
    
    func storeManagerDidReceiveMessage(_ message: String) {
        alert(with: Messages.productRequestStatus, message: message)
    }
}

