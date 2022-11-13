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

class InterstitialBaseViewController: UIViewController, SizeProvider {
    
    // Integration case ad size, for interstitial default size 320x480
    // This property is later setuped with an IntegrationCase size
    var adSize: CGSize = CGSize(width: 320, height: 480)
    
    convenience init() {
        self.init(nibName: "InterstitialBaseViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
