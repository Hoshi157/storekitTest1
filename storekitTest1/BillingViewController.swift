//
//  BillingViewController.swift
//  storekitTest1
//
//  Created by 福山帆士 on 2020/07/21.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit
import StoreKit

class BillingViewController: UIViewController {
    
    let productIdentifiers = ["productIdentifiers1"]
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("戻る", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        return button
    }()
    
    private let purchaseButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        button.setTitle("課金開始", for: .normal)
        button.addTarget(self, action: #selector(purchaseButtonPressed), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(purchaseButton)
        
        let dismissConstraints = [
            dismissButton.widthAnchor.constraint(equalToConstant: 200),
            dismissButton.heightAnchor.constraint(equalToConstant: 50),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ]
        
        NSLayoutConstraint.activate(dismissConstraints)
        
        let purchaseButtonConstraints = [
            purchaseButton.widthAnchor.constraint(equalToConstant: 200),
            purchaseButton.heightAnchor.constraint(equalToConstant: 50),
            purchaseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            purchaseButton.bottomAnchor.constraint(equalTo: dismissButton.topAnchor, constant: -50)
        ]
        
        NSLayoutConstraint.activate(purchaseButtonConstraints)

        // Do any additional setup after loading the view.
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func purchaseButtonPressed() {
        startPuchase(productIdentifer: productIdentifiers.first!)
    }
    
    // 課金開始
    private func startPuchase(productIdentifer: String) {
        
        PurchaseManeger.shared.delegate = self
        
        // プロダクト情報を取得
        ProductManager.request(productIdentifir: productIdentifer, completion: { [weak self] (product: SKProduct?, error: Error?) in
            guard error == nil, let product = product else {
                self?.purchaseManager(PurchaseManeger.shared, didFailTransactionWithError: error)
                return
            }
            // 課金処理開始
            PurchaseManeger.shared.purchase(product: product)
        })
    }
    
    // リストア開始
    private func startRestore() {
        // デリゲート設定
        PurchaseManeger.shared.delegate = self
        
        // リストア開始
        PurchaseManeger.shared.restore()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BillingViewController: PurchaseManagerDelegate {
    
    func purchaseManager(_ purchaseManager: PurchaseManeger, didFinishTransaction transaction: SKPaymentTransaction, decitionHandler: (Bool) -> Void) {
        // 課金終了時に呼び出される
        
            let ac = UIAlertController(title: "purchase finish", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true)
        
        // コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部終了, false: 課金処理中断)
        decitionHandler(true)
    }
    
    func purchaseManager(_ purchaseManager: PurchaseManeger, didFinishUntreatedTransaction transaction: SKPaymentTransaction, decitionHandler: (Bool) -> Void) {
        // 課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時)
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "purchase finish(Untreated.)", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true)
            
        }
        decitionHandler(true)
    }
    
    func purchaseManager(_ purchaseManager: PurchaseManeger, didFailTransactionWithError error: Error?) {
        // 課金失敗時に呼び出される
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "purchase fail", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true)
        }
        
    }
    
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManeger) {
        // リストア終了時に呼び出される(個々のトランザクションは"課金終了"で処理)
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "restore finish", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true)
        }
    }
    
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManeger) {
        // 承認待ち状態時に呼び出される
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "purchase deferred", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true)
        }
    }
}
