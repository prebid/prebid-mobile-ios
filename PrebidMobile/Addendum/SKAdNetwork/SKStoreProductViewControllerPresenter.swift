/*   Copyright 2018-2025 Prebid.org, Inc.
 
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
import StoreKit

class SKStoreProductViewControllerPresenter: NSObject {
    
    private weak var presentingViewController: UIViewController?
    
    func present(from viewController: UIViewController, using productParameters: [String: Any]) {
        self.presentingViewController = viewController
        
        DispatchQueue.main.async {
            let skadnController = SKStoreProductViewController() 
            self.presentingViewController?.present(skadnController, animated: true)
            skadnController.loadProduct(withParameters: productParameters) { _, error in
                if let error {
                    Log.error("Error occurred during SKStoreProductViewController product loading: \(error.localizedDescription)")
                }
            }
        }
    }
}
