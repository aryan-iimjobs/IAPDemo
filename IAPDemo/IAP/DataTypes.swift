//
//  DataTypes.swift
//  ApplePayDemo
//
//  Created by Aryan Sharma on 18/06/20.
//  Copyright © 2020 Iimjobs. All rights reserved.
//

// Abstract:
// Handles the application's configuration information.

import Foundation

// MARK: - Message

/// A structure of messages that will be displayed to users.
struct Messages {
    static let appStoreIdentiferDidnotMatch = "Product Identifier from the App Store didn't match with local identifer."
    static let cannotMakePayments = "\(notAuthorized) \(installing)"
    static let couldNotFind = "Could not find resource file:"
    static let deliverContent = "Deliver content for"
    static let deferred = "Allow the user to continue using your app."
    static let error = "Error: "
    static let emptyString = ""
    static let failed = "failed."
    static let installing = "In-App Purchases may be restricted on your device."
    static let notAuthorized = "You are not authorized to make payments."
    static let okButton = "OK"
    static let purchaseOf = "Purchase of"
    static let purchaseStatus = "Purchase Status"
    static let productRequestStatus = "Product Request Status"
    static let removed = "was removed from the payment queue."
    static let status = "Status"
    static let unknownPaymentTransaction = "Unknown payment transaction case."
    static let updateResource = "Update it with your product identifiers to retrieve product information."
}

// MARK: - Resource File

/// A structure that specifies the name and file extension of a resource file, which contains the product identifiers to be queried.
struct ProductIdentifiers {
    /// Name of the resource file containing the product identifiers.
    let name = "ProductIds"
    /// Filename extension of the resource file containing the product identifiers.
    let fileExtension = "plist"
    
    var isEmpty: String {
        return "\(name).\(fileExtension) is empty. \(Messages.updateResource)"
    }
    
    var wasNotFound: String {
        return "\(Messages.couldNotFind) \(name).\(fileExtension)."
    }
    
    /// - returns: An array with the product identifiers to be queried.
    var identifiers: [String]? {
        guard let path = Bundle.main.path(forResource: self.name, ofType: self.fileExtension) else { return nil }
        return NSArray(contentsOfFile: path) as? [String]
    }
}
