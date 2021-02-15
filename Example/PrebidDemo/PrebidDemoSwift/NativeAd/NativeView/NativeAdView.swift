/*   Copyright 2019-2020 Prebid.org, Inc.

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

public class NativeAdView: UIView {

    @IBOutlet public weak var iconImageView: UIImageView!
    @IBOutlet public weak var mainImageView: UIImageView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var bodyLabel: UILabel!
    @IBOutlet public weak var callToActionButton: UIButton!
    @IBOutlet public weak var sponsoredLabel: UILabel!

}
