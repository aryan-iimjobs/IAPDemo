//
//  ViewController.swift
//  ApplePayDemo
//
//  Created by Aryan Sharma on 17/06/20.
//  Copyright © 2020 Iimjobs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var subscribeBtn: UIButton!
    
    @IBAction func subscribeAction(_ sender: Any) {
        StoreManager.shared.startProductRequest(with: ["com.highorbit.iimjobs.subscrbe"])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
}

