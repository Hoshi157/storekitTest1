//
//  ProductManager.swift
//  storekitTest1
//
//  Created by 福山帆士 on 2020/07/21.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import Foundation
import StoreKit

public enum ProductManagerError: Error {
    case emptyProductIdentifiers
    case noVaidProducts
    case notMatchProductIdentifier
    case skError(massage: String)
    case unkown
    
    public var localizedDescription: String {
        switch self {
        case .emptyProductIdentifiers:
            return "プロダクトIDが指定されていません"
        case .noVaidProducts:
            return "有効なプロダクトを取得できませんでした"
        case .notMatchProductIdentifier:
            return "指定したプロダクトIDと取得したプロダクトIDが一致していません"
        case .skError(let message):
            return message
        default:
            return "不明なエラー"
        }
    }
}

final public class ProductManager: NSObject {
    // 保持用
    static private var managers: Set<ProductManager> = Set()
    // 完了通知
    public typealias Completion = ([SKProduct], Error?) -> Void
    // 完了通知
    public typealias CompletionForSingle = (SKProduct?, Error?) -> Void
    // 完了通知用
    private var completion: Completion
    // 価格問い合わせ用オブジェクト(保持用)
    private var productRequest: SKProductsRequest?
    // 初期化
    private init(completion: @escaping Completion) {
        self.completion = completion
    }
    
    
    // 課金アイテム情報を取得(複数)
    // productIdentifirs: プロダクトID配列
    class func request(productIdentifirs: [String], completion: @escaping Completion) {
        
        guard !productIdentifirs.isEmpty else {
            // productIDがセットされていない
            completion([], ProductManagerError.emptyProductIdentifiers)
            return
        }
        
        let productManager = ProductManager(completion: completion)
        // Set<~~~>は配列の重複を許さない
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifirs))
        productRequest.delegate = productManager
        productRequest.start()
        productManager.productRequest = productRequest
        managers.insert(productManager)
    }
    
    // 課金アイテム情報を取得(ひとつ)
    class func request(productIdentifir: String, completion: @escaping CompletionForSingle) {
        
        ProductManager.request(productIdentifirs: [productIdentifir]) { (products, error) in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let product = products.first else {
                // 有効なプロダクトを取得できなかった
                completion(nil, ProductManagerError.noVaidProducts)
                return
            }
            
            guard product.productIdentifier == productIdentifir else {
                completion(nil, ProductManagerError.notMatchProductIdentifier)
                return
            }
            
            completion(product, nil)
        }
    }
}

extension ProductManager: SKProductsRequestDelegate {
   
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let error = !response.products.isEmpty ? nil : ProductManagerError.noVaidProducts
        completion(response.products, error)
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        completion([], ProductManagerError.skError(massage: error.localizedDescription))
        ProductManager.managers.remove(self)
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        ProductManager.managers.remove(self)
    }
}

public extension SKProduct {
    // 価格
    var localizedPrice: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = priceLocale
        return numberFormatter.string(from: price)
    }
}
