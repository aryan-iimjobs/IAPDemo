//
//  StoreManager.swift
//  ApplePayDemo
//
//  Created by Aryan Sharma on 18/06/20.
//  Copyright © 2020 Iimjobs. All rights reserved.
//

import UIKit
import StoreKit

// MARK: - StoreManagerDelegate

protocol StoreManagerDelegate: AnyObject {
    /// Provides the delegate with the App Store's response. As of now provides specific product for Pro subscription if successful.
    func storeManagerDidReceiveProduct(_ product: SKProduct)
    
    /// Provides the delegate with the error encountered during the product request.
    func storeManagerDidReceiveMessage(_ message: String)
}

/**
Retrieves product information from the App Store using SKRequestDelegate, SKProductsRequestDelegate, SKProductsResponse, and SKProductsRequest.
Notifies its observer with a list of products available for sale along with a list of invalid product identifiers.
Logs an error message if the product request failed.
*/
class StoreManager: NSObject {

    // MARK: - Types
    static let shared = StoreManager()
    
    //MARK: - Properties
    /// Keeps a strong reference to the product request.
    fileprivate var productRequest: SKProductsRequest!
    
    /// Keeps track of all valid products. These products are available for sale in the App Store.
    fileprivate var availableProducts = [SKProduct]()
    
    /// Keeps track of all invalid product identifiers.
    fileprivate var invalidProductIdentifiers = [String]()
    
    /// Resource file, which contains the product identifiers to be queried.
    fileprivate let resourceFile = ProductIdentifiers()
    
    /// Prodcut identifiers requested from the app store
    fileprivate var identifiersRequested = [String]()
    
    weak var delegate: StoreManagerDelegate?
    
    // MARK: - Initializer
    
    private override init() {}
    
    // MARK: - Request Product Information
    
    /// Starts the product request with the identifiers from ProductIds.plist.
    func startProductRequest() {
        if StoreObserver.shared.isAuthorizedForPayments {
            guard let identifiers = resourceFile.identifiers else {
                // Warn the user that the resource file could not be found.
                print("print - \(Messages.status + resourceFile.wasNotFound)")
                return
            }
            
            if !identifiers.isEmpty {
                identifiersRequested = identifiers
                // Fetch product information.
                fetchProducts(matchingIdentifiers: identifiers)
            } else {
                // Warn the user that the resource file does not contain anything.
                print("print - \(Messages.status + resourceFile.isEmpty)")
            }
        } else {
            // Warn the user that they are not allowed to make purchases.
            print("print - \(Messages.status + Messages.cannotMakePayments)")
        }
    }
    
    /// Fetches information about your products from the App Store.
    /// - Tag: FetchProductInformation
    fileprivate func fetchProducts(matchingIdentifiers identifiers: [String]) {
        // Create a set for the product identifiers.
        let productIdentifiers = Set(identifiers)
        
        // Initialize the product request with the above identifiers.
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        
        // Send the request to the App Store.
        productRequest.start()
    }
}

// MARK: - SKProductsRequestDelegate

/// Extends StoreManager to conform to SKProductsRequestDelegate.
extension StoreManager: SKProductsRequestDelegate {
    /// Used to get the App Store's response to your request and notify your observer.
    /// - Tag: ProductRequest
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // products contains products whose identifiers have been recognized by the App Store. As such, they can be purchased.
        if !response.products.isEmpty {
            availableProducts = response.products
        }
        
        // invalidProductIdentifiers contains all product identifiers not recognized by the App Store.
        if !response.invalidProductIdentifiers.isEmpty {
            invalidProductIdentifiers = response.invalidProductIdentifiers
        }
        
        if !availableProducts.isEmpty {
            // Check if the received identifer is for Pro subscription.
            if let identifier = identifiersRequested.first, let product = availableProducts.first, product.productIdentifier == identifier {
                DispatchQueue.main.async {
                    self.delegate?.storeManagerDidReceiveProduct(product)
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.storeManagerDidReceiveMessage(Messages.appStoreIdentiferDidnotMatch)
                }
            }
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        
    }
}

// MARK: - SKRequestDelegate

/// Extends StoreManager to conform to SKRequestDelegate.
extension StoreManager: SKRequestDelegate {
    /// Called when the product request failed.
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("print - \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.delegate?.storeManagerDidReceiveMessage(error.localizedDescription)
        }
    }
    
    
}
