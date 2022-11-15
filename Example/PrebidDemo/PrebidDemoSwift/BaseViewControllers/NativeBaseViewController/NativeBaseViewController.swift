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

fileprivate let nativeBaseViewControllerNibName = "NativeBaseViewController"

/// Base controller for native integration cases, provides title, body and sponsoredBy label, main and icon image views, callToAction button
/// For more details look at NativeBaseViewController xib
class NativeBaseViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var callToActionButton: UIButton!
    @IBOutlet weak var sponsoredLabel: UILabel!
    
    convenience init() {
        self.init(nibName: nativeBaseViewControllerNibName, bundle: nil)
    }
}
