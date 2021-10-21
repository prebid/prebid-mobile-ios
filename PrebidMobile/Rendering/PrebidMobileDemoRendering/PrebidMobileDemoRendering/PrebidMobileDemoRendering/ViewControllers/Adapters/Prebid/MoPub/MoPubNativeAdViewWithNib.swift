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
import MoPubSDK

class MoPubNativeAdViewWithNib: UIView,  MPNativeAdRendering {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    //MARK: - MPNativeAdRendering
    
    static func nibForAd() -> UINib {
        return UINib(nibName: "MoPubNativeAdViewWithNib", bundle: nil)
    }
    
    func nativeMainTextLabel() -> UILabel? {
        return mainTextLabel
    }

    func nativeTitleTextLabel() -> UILabel? {
        return titleLabel
    }

    func nativeIconImageView() -> UIImageView? {
        return iconImageView
    }

    func nativeMainImageView() -> UIImageView? {
        return mainImageView
    }
}
