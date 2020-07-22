//
//  PurchaseManager.swift
//  storekitTest1
//
//  Created by 福山帆士 on 2020/07/21.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import Foundation
import StoreKit

// 課金エラー
struct PurchaseManagerErrors: OptionSet, Error {
    public let rawValue: Int
    static let cannotMakePayments = PurchaseManagerErrors(rawValue: 1 << 0)
    static let purchasing         = PurchaseManagerErrors(rawValue: 1 << 1)
    static let restoreing         = PurchaseManagerErrors(rawValue: 1 << 2)
    
    public var localizedDescription: String {
        var message = ""
        
        if self.contains(.cannotMakePayments) {
            message += "設定で購入が無効になっています"
        }
        if self.contains(.purchasing) {
            message += "課金処理中です"
        }
        if self.contains(.restoreing) {
            message += "リストア中です"
        }
        
        return message
    }
}

// 課金するためのクラス
open class PurchaseManeger: NSObject {
    
    public static var shared = PurchaseManeger() // static ???
    
    weak var delegate: PurchaseManagerDelegate?
    
    private var productIdentigfier: String?
    
    private var isRestore: Bool = false
    
    // 課金開始
    public func purchase(product: SKProduct) {
        
        var errors: PurchaseManagerErrors = []
        
        if SKPaymentQueue.canMakePayments() == false {
            // 設定で購入が無効
            errors.insert(.cannotMakePayments)
        }
        
        if productIdentigfier != nil {
            errors.insert(.purchasing)
        }
        
        if isRestore == true {
            errors.insert(.restoreing)
        }
        
        // エラーがあれば終了
        guard errors.isEmpty else {
            delegate?.purchaseManager(self, didFailTransactionWithError: errors)
            return
        }
        
        // 未処理のトランザクションがあればそれを利用
        let transactions = SKPaymentQueue.default().transactions
        
        for transaction in transactions {
            if transaction.transactionState != .purchased { continue }
            if transaction.payment.productIdentifier == product.productIdentifier {
                guard let window = UIApplication.shared.delegate?.window else { continue }
                let ac = UIAlertController(title: nil, message: "\(product.localizedTitle)は購入処理が中断されていました。\nこのまま無料でダウンロードできます", preferredStyle: .alert)
                let action = UIAlertAction(title: "続行", style: .default, handler: { [weak self] (action: UIAlertAction) in
                    if let strongSelf = self {
                        strongSelf.productIdentigfier = product.productIdentifier
                        strongSelf.completeTransaction(transaction)
                    }
                })
                DispatchQueue.main.async {
                    ac.addAction(action)
                    window?.rootViewController?.present(ac, animated: true)
                }
                return
            }
        }
        
        // 課金処理開始
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        productIdentigfier = product.productIdentifier
    }
    
    // リストア開始
    public func restore() {
        if isRestore == false {
            isRestore = true
            SKPaymentQueue.default().restoreCompletedTransactions()
        }else {
            delegate?.purchaseManager(self, didFailTransactionWithError: PurchaseManagerErrors.restoreing)
        }
    }
    
    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        // 課金失敗
        delegate?.purchaseManager(self, didFailTransactionWithError: transaction.error)
        productIdentigfier = nil
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deferredTransaction(_ transaction: SKPaymentTransaction) {
        // 承認待ち
        delegate?.purchaseManagerDidDeferred(self)
        productIdentigfier = nil
    }
    
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        if transaction.payment.productIdentifier == productIdentigfier {
            // 課金終了
            delegate?.purchaseManager(self, didFinishTransaction: transaction, decitionHandler: { (complete) in
                if complete == true {
                    // トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
            productIdentigfier = nil
        }else {
            // 課金終了(以前中断された課金処理)
            delegate?.purchaseManager(self, didFinishUntreatedTransaction: transaction, decitionHandler: { (complete) in
                if complete == true {
                    // トランザクション終了
                 SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
        }
    }
    
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        // リストア
        delegate?.purchaseManager(self, didFinishTransaction: transaction, decitionHandler: { (complete) in
            if complete == true {
                // トランザクション終了
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        })
    }
    
    
}

extension PurchaseManeger: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // 課金状態が更新されるたびに呼ばれる
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                // 課金中
                break
            case .purchased:
                // 課金完了
                completeTransaction(transaction)
                break
            case .failed:
                // 課金失敗
                failedTransaction(transaction)
                break
            case .restored:
                // リストア
                restoreTransaction(transaction)
                break
            case .deferred:
                // 承認待ち
                deferredTransaction(transaction)
                break
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        // リストア失敗時に呼ばれる
        delegate?.purchaseManager(self, didFailTransactionWithError: error)
        isRestore = false
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // リストア完了時に呼ばれる
        delegate?.purchaseManagerDidFinishRestore(self)
        isRestore = false
    }
    
}



protocol PurchaseManagerDelegate: NSObjectProtocol {
    // 課金完了
    func purchaseManager(_ purchaseManager: PurchaseManeger, didFinishTransaction transaction: SKPaymentTransaction, decitionHandler: (_ complete: Bool) -> Void)
    // 課金完了(中断していたもの)
    func purchaseManager(_ purchaseManager: PurchaseManeger, didFinishUntreatedTransaction transaction: SKPaymentTransaction, decitionHandler: (_ complete: Bool) -> Void)
    // リストア完了
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManeger)
    // 課金失敗
    func purchaseManager(_ purchaseManager: PurchaseManeger, didFailTransactionWithError error: Error?)
    // 承認待ち
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManeger)
}

extension PurchaseManagerDelegate {
    func purchaseManager(_ purchaseManager: PurchaseManeger, didFinishTransaction transaction: SKPaymentTransaction, decitionHandler: (_ complete: Bool) -> Void) {
        decitionHandler(false)
    }
    
    func purchaseManager(_ purchaseManager: PurchaseManeger, didFinishUntreatedTransaction transaction: SKPaymentTransaction, decitionHandler: (_ complete: Bool) -> Void) {
        decitionHandler(false)
    }
    
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManeger) {}
    
    func purchaseManager(_ purchaseManager: PurchaseManeger, didFailTransactionWithError error: Error?) {}
    
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManeger) {}
}
