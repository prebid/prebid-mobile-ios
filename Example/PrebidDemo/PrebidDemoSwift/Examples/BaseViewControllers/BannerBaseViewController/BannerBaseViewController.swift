/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

fileprivate let bannerBaseViewControllerNibName = "BannerBaseViewController"

/// Base controller, which provides banner controls, i.e. banner view
class BannerBaseViewController: UIViewController {
    
    @IBOutlet weak var bannerView: UIView!
    
    // Integration case ad size, for banner default size 320x50
    // This property is later setuped with an IntegrationCase size
    var adSize = CGSize(width: 320, height: 50)
    
    convenience init(adSize: CGSize) {
        self.init(nibName: bannerBaseViewControllerNibName, bundle: nil)
        self.adSize = adSize
    }
    
    convenience init() {
        self.init(nibName: bannerBaseViewControllerNibName, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        bannerView.constraints.first { $0.firstAttribute == .width }?.constant = adSize.width
        bannerView.constraints.first { $0.firstAttribute == .height }?.constant = adSize.height
    }
}
