//
//  StoreObserver.swift
//  ApplePayDemo
//
//  Created by Aryan Sharma on 18/06/20.
//  Copyright © 2020 Iimjobs. All rights reserved.
//

import UIKit
import StoreKit

// MARK: - StoreObserverDelegate

protocol StoreObserverDelegate: AnyObject {
    /// Tells the delegate that the purchase was successful for the given transaction.
    /// Executes a completion handler after purchased content is provided to the user. True if provided else false.
    func storeObserverPurchased(_ transaction: SKPaymentTransaction, completionHandler: @escaping(Bool) -> Void)
    
    /// Provides the delegate with messages.
    func storeObserverDidReceiveMessage(_ message: String)
}

///Implements the SKPaymentTransactionObserver protocol. Handles purchasing and restoring products using paymentQueue:updatedTransactions:.
class StoreObserver: NSObject {
    
    // MARK: - Types
    
    static let shared = StoreObserver()
    
    // MARK: - Properties
    
    /**
     Indicates whether the user is allowed to make payments.
     - returns: true if the user is allowed to make payments and false, otherwise. Tell StoreManager to query the App Store when the user is
     allowed to make payments and there are product identifiers to be queried.
     */
    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    /// Keeps track of all purchases.
    var purchased = [SKPaymentTransaction]()
    
    weak var delegate: StoreObserverDelegate?
    
    // MARK: - Initializer
    
    private override init() {
        super.init()
    }
    
    // MARK: - Submit Payment Request
    
    /// Create and add a payment request to the payment queue.
    func buy(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        print("print - Added product to PaymentQueue")
        SKPaymentQueue.default().add(payment)
    }
}

// MARK: - Handle Payment Transactions

extension StoreObserver {
    
    /// Handles successful purchase transactions.
    fileprivate func handlePurchased(_ transaction: SKPaymentTransaction) {
        purchased.append(transaction)
        print("\(Messages.deliverContent) \(transaction.payment.productIdentifier).")

        DispatchQueue.main.async {
            self.delegate?.storeObserverPurchased(transaction, completionHandler: { isSuccess in
                if isSuccess {
                    // Finish the successful transaction.
                    SKPaymentQueue.default().finishTransaction(transaction)
                } else {
                    // #### App was not able to provide purchased product. ####
                }
            })
        }
    }
    
    /// Handles failed purchase transactions.
    fileprivate func handleFailed(_ transaction: SKPaymentTransaction) {
        var message = "\(Messages.purchaseOf) \(transaction.payment.productIdentifier) \(Messages.failed)"
        
        if let error = transaction.error {
            message += "\n\(Messages.error) \(error.localizedDescription)"
            print("print - \(Messages.error) \(error.localizedDescription)")
        }
        
        // Do not send any notifications when the user cancels the purchase.
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            DispatchQueue.main.async {
                self.delegate?.storeObserverDidReceiveMessage(message)
            }
        }
        // Finish the failed transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}

// MARK: - SKPaymentTransactionObserver

/// Extends StoreObserver to conform to SKPaymentTransactionObserver.
extension StoreObserver: SKPaymentTransactionObserver {
    /// Called when there are transactions in the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            // A transaction that is being processed by the App Store.
            case .purchasing: break
            // Do not block the UI. Allow the user to continue using the app.
            case .deferred: print(Messages.deferred)
            // The purchase was successful.
            case .purchased: handlePurchased(transaction)
            // The transaction failed.
            case .failed: handleFailed(transaction)
            // There're restored products.
            // Restoring for current product i.e. non-renewing subscription will be handeled by our own server.
            case .restored: break
            @unknown default: fatalError(Messages.unknownPaymentTransaction)
            }
        }
    }
    
    /// Logs all transactions that have been removed from the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("print - \(transaction.payment.productIdentifier) \(Messages.removed)")
        }
    }
}
