//
//  ViewController.swift
//  storekitTest1
//
//  Created by 福山帆士 on 2020/07/21.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let presentButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        button.setTitle("課金ページへ", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(presentVC), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        presentButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(presentButton)
        
        let presentButtonContraints = [
            presentButton.widthAnchor.constraint(equalToConstant: 200),
            presentButton.heightAnchor.constraint(equalToConstant: 50),
            presentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            presentButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ]
        
        NSLayoutConstraint.activate(presentButtonContraints)
    }
    
    @objc func presentVC() {
        let billingVC = BillingViewController()
        billingVC.modalPresentationStyle = .fullScreen
        present(billingVC, animated: true)
    }


}

