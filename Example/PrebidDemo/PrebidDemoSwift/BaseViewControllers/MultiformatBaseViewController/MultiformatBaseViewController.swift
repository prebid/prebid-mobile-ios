/*   Copyright 2019-2023 Prebid.org, Inc.
 
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

fileprivate let multiformatBaseViewControllerNibName = "MultiformatBaseViewController"

class MultiformatBaseViewController: UIViewController {
    
    @IBOutlet weak var nativeView: UIStackView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var callToActionButton: UIButton!
    @IBOutlet weak var sponsoredLabel: UILabel!
    
    @IBOutlet weak var bannerView: UIView!
    
    @IBOutlet weak var configIdLabel: UILabel!
    
    // Integration case ad size, for banner default size 320x50
    // This property is later setuped with an IntegrationCase size
    var adSize = CGSize(width: 320, height: 50)
    
    convenience init() {
        self.init(nibName: multiformatBaseViewControllerNibName, bundle: nil)
    }
    
    convenience init(adSize: CGSize) {
        self.init(nibName: multiformatBaseViewControllerNibName, bundle: nil)
        self.adSize = adSize
    }
}
