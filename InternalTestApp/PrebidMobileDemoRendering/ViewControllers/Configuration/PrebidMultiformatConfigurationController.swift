/*   Copyright 2018-2023 Prebid.org, Inc.

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

import Foundation
import Eureka

class PrebidMultiformatConfigurationController: BaseConfigurationController {
    
    private(set) var includeBanner = true
    private(set) var includeVideo = true
    private(set) var includeNative = true
    
    private var loadButton: UIButton?
    
    override var loadSection: Section {
        return Section(header: "Ad Formats", footer: nil) { section in
            var footer = HeaderFooterView<UIButton>(.class)
            footer.height = {44}
            footer.onSetupView = { [weak self] button, _ in
                guard let self = self else { return }
                button.setTitle("Load the Ad", for: .normal)
                button.setTitleColor(.systemBlue, for: .normal)
                button.setTitleColor(.systemGray, for: .disabled)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                button.addTarget(self, action: #selector(self.onLoad(_:)), for: .touchUpInside)
                button.accessibilityIdentifier = "load_ad"
                
                self.loadButton = button
            }
            
            section.footer = footer
        }
        <<< includeBannerCheck
        <<< includeVideoCheck
        <<< includeNativeCheck
    }
    
    var includeBannerCheck: CheckRow {
        return CheckRow() { row in
            row.title = "Banner"
            row.value = true
            row.onChange { [weak self] row in
                guard let self = self else { return }
                
                self.includeBanner = row.value!
                
                self.loadButton?.isEnabled = self.canLoadAd()
            }
        }
    }
    
    var includeVideoCheck: CheckRow {
        return CheckRow() { row in
            row.title = "Video"
            row.value = true
            row.onChange { [weak self] row in
                guard let self = self else { return }
                
                self.includeVideo = row.value!
                
                self.loadButton?.isEnabled = self.canLoadAd()
            }
        }
    }
    
    var includeNativeCheck: CheckRow {
        return CheckRow() { row in
            row.title = "Native"
            row.value = true
            row.onChange { [weak self] row in
                guard let self = self else { return }
                
                self.includeNative = row.value!
                
                self.loadButton?.isEnabled = self.canLoadAd()
            }
        }
    }
    
    private func canLoadAd() -> Bool {
        return (includeBanner && includeVideo) || (includeBanner && includeNative) || (includeVideo && includeNative)
    }
}
