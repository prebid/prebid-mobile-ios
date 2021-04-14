//
//  PrebidPresentationViewController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit

class PrebidPresentationViewController: UIViewController {
    
    var prebidConfigId: String!
    
    var navigationVC: UINavigationController?
    var isLoaded = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isLoaded {
            isLoaded = true
            let adapterVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdapterViewController") as? AdapterViewController
            adapterVC?.view.backgroundColor = UIColor.white
            adapterVC?.title = title
            
            adapterVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Dismiss",
                                                                               style: .plain,
                                                                               target: self,
                                                                               action: #selector(backAction))
            
            let oxbInterstitialController = PrebidInterstitialController(rootController: adapterVC!)
            oxbInterstitialController.prebidConfigId = prebidConfigId
            adapterVC?.setup(adapter: oxbInterstitialController)
            
            navigationVC = UINavigationController(rootViewController: adapterVC!)
            navigationVC?.isNavigationBarHidden = false
            present(navigationVC!, animated: true, completion: nil)
            
        }
    }
    
    @objc func backAction() {
        navigationVC?.dismiss(animated: false, completion: {
            self.navigationVC = nil
            self.navigationController?.popToRootViewController(animated: true)
        })
    }

}
