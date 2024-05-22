/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import PrebidMobile

class PrebidPresentationViewController: UIViewController {
    
    var prebidConfigId: String!

    var adFormats: Set<AdFormat>?
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
            
            let interstitialController = PrebidInterstitialController(rootController: adapterVC!)
            interstitialController.prebidConfigId = prebidConfigId
            interstitialController.adFormats = adFormats
            adapterVC?.setup(adapter: interstitialController)
            
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
