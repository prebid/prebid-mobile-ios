/*   Copyright 2018-2025 Prebid.org, Inc.
 
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

@objc(PBMSKOverlayManager) @objcMembers
public class SKOverlayManager: NSObject {
    
    private weak var viewControllerForPresentation: UIViewController?
    private weak var windowScene: NSObject?
    
    public init(viewControllerForPresentation: UIViewController) {
        self.viewControllerForPresentation = viewControllerForPresentation
        super.init()
    }
    
    public func presentSKOverlay(with skadnInfo: ORTBBidExtSkadn, isCompanionAd: Bool) {
        guard #available(iOS 14.0, *) else { return }
        
        guard let scene = viewControllerForPresentation?.view.window?.windowScene else {
            Log.warn("SKOverlay couldn't be presented because there is no window scene.")
            return
        }
        
        guard let config = buildConfig(with: skadnInfo) else {
            return
        }
        
        windowScene = scene
        
        let delayInSeconds = (isCompanionAd ? skadnInfo.skoverlay?.endcarddelay : skadnInfo.skoverlay?.delay) ?? 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delayInSeconds.intValue)) {
            let overlay = SKOverlay(configuration: config)
            overlay.present(in: scene)
        }
    }
    
    public func dismissSKOverlay() {
        guard #available(iOS 14.0, *) else { return }
        
        guard let windowScene = self.windowScene as? UIWindowScene else {
            return
        }
        
        SKOverlay.dismiss(in: windowScene)
        
        self.windowScene = nil
        self.viewControllerForPresentation = nil
    }
    
    @available(iOS 14.0, *)
    private func buildConfig(with skadnInfo: ORTBBidExtSkadn) -> SKOverlay.AppConfiguration? {
        guard let skoverlay = skadnInfo.skoverlay else {
            Log.warn("SDK failed to build SKOverlay configuration. `skoverlay` dictionary is nil.")
            return nil
        }
        
        guard let itunesitem = skadnInfo.itunesitem?.stringValue else {
            Log.warn("SDK failed to build SKOverlay configuration. `itunesitem` is nil.")
            return nil
        }
        
        let position: SKOverlay.Position = skoverlay.pos == 0 ? .bottom : .bottomRaised
        
        let config = SKOverlay.AppConfiguration(
            appIdentifier: itunesitem,
            position: position
        )
        
        config.userDismissible = skoverlay.dismissible != 0
        
        return config
    }
}
