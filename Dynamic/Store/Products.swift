//
//  Products.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/16/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit

import Foundation
import StoreKit
import SwiftKeychainWrapper

protocol PurchaseDelegate {
    func didFinishPurchase()
}

struct Products {
    
    static let productIds : Set<String> = ["03", "04" ]
    
    static let store = IAPHelper(productIds: Products.productIds)
    
    static var delegate : PurchaseDelegate?
    
    static func handlePurchase(purchaseIdentifier: String) {
        if productIds.contains(purchaseIdentifier) {
            store.purchasedProducts.insert(purchaseIdentifier)
        }
        delegate?.didFinishPurchase()
    }
    
}

public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products:[SKProduct]?) -> Void

class IAPHelper : NSObject {
    
    public var purchasedProducts = Set<String>()
    private let productIdentifiers : Set<String>
    private var productsRequest : SKProductsRequest?
    private var productsRequestCompletionHandler : ProductsRequestCompletionHandler?
    
    init(productIds: Set<String>) {
        productIdentifiers = productIds
        purchasedProducts = Set(productIds.filter {
            KeychainWrapper.standard.bool(forKey: $0) ?? false
        })
        super.init()
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func isPurchased() -> Bool {
        return purchasedProducts.contains("01") ||
            purchasedProducts.contains("04") ||
            purchasedProducts.contains("03") ||
            LocalStorage.shouldBeFree || true
    }
    
}

extension IAPHelper {
    
    func buyProduct(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
}


extension IAPHelper : SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        productsRequestCompletionHandler?(true, response.products)
        productsRequestCompletionHandler = .none
        productsRequest = .none
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        productsRequestCompletionHandler?(false, nil)
        productsRequestCompletionHandler = .none
        productsRequest = .none
    }
}
