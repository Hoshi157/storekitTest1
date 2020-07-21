//
//  BillingViewController.swift
//  storekitTest1
//
//  Created by 福山帆士 on 2020/07/21.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit

class BillingViewController: UIViewController {
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("戻る", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        
        let dismissConstraints = [
            dismissButton.widthAnchor.constraint(equalToConstant: 200),
            dismissButton.heightAnchor.constraint(equalToConstant: 50),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ]
        
        NSLayoutConstraint.activate(dismissConstraints)

        // Do any additional setup after loading the view.
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
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
