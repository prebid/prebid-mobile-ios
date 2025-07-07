//
//  ViewController.swift
//  SPMTestApp
//
//  Created by James on 6/30/25.
//

import UIKit

import PrebidMobile

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print(Prebid.shared.version)
    }


}

