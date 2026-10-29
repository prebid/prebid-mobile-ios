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

import Foundation

/// Global singleton for the SDK's access to plugin renderers. The renderers are stored in
/// `Registries.renderer`, which `Prebid.register(_:as:)` writes to.
class PrebidMobilePluginRegister: NSObject {
    
    static let shared = PrebidMobilePluginRegister()
    
    /// Default PrebidMobile SDK renderer
    var sdkRenderer: PrebidMobilePluginRenderer {
        if let renderer = getPluginRenderer(for: PREBID_MOBILE_RENDERER_NAME) {
            return renderer
        }
        
        Log.error("SDK couldn't find \(PREBID_MOBILE_RENDERER_NAME) in plugin register. The new instance of \(PREBID_MOBILE_RENDERER_NAME) will be created.")
        return PrebidRenderer()
    }
    
    /// Calls the renderers' event delegate methods, in order, off the caller's thread.
    private let eventDelegateQueue = DispatchQueue(label: "PrebidMobilePluginRegisterQueue")
    
    private var registry: PluginRegistry<any PrebidMobilePluginRenderer> {
        Registries.renderer.typed
    }
    
    private override init() {
        super.init()
    }
    
    /// Register plugin as renderer. A renderer whose name is already registered is ignored.
    func registerPlugin(_ renderer: PrebidMobilePluginRenderer) {
        registry.add(renderer)
    }
    
    /// Unregisters the renderer with the same name as `renderer`.
    func unregisterPlugin(_ renderer: PrebidMobilePluginRenderer) {
        registry.remove(renderer)
    }
    
    /// Returns whether this renderer instance is registered.
    func containsPlugin(_ renderer: PrebidMobilePluginRenderer) -> Bool {
        registry.active.contains { $0 === renderer }
    }
    
    /// Register event delegate
    func registerEventDelegate(
        _ pluginEventDelegate: PluginEventDelegate,
        adUnitConfigFingerprint: String
    ) {
        let renderers = registry.active
        
        eventDelegateQueue.async {
            renderers.forEach {
                $0.registerEventDelegate?(
                    pluginEventDelegate: pluginEventDelegate,
                    adUnitConfigFingerprint: adUnitConfigFingerprint
                )
            }
        }
    }
    
    /// Unregister event delegate
    func unregisterEventDelegate(
        _ pluginEventDelegate: PluginEventDelegate,
        adUnitConfigFingerprint: String
    ) {
        let renderers = registry.active
        
        eventDelegateQueue.async {
            renderers.forEach {
                $0.unregisterEventDelegate?(
                    pluginEventDelegate: pluginEventDelegate,
                    adUnitConfigFingerprint: adUnitConfigFingerprint
                )
            }
        }
    }
    
    /// Returns the registered renderer according to the preferred renderer name in the bid response.
    /// If no preferred renderer is found, it returns PrebidRenderer to perform default behavior.
    /// Once bid is win we want to resolve the best PluginRenderer candidate to render the ad.
    func getPluginForPreferredRenderer(bid: Bid) -> PrebidMobilePluginRenderer {
        guard let preferredRendererName = bid.pluginRendererName,
              let preferredPlugin = getPluginRenderer(for: preferredRendererName),
              preferredPlugin.version == bid.pluginRendererVersion
        else {
            return sdkRenderer
        }
        
        return preferredPlugin
    }
    
    /// The registered renderers in registration order.
    func getAllPlugins() -> [PrebidMobilePluginRenderer] {
        registry.active
    }
    
    func getAllPluginsJSONRepresentation() -> [[String: Any]] {
        return PrebidMobilePluginRegister
            .shared
            .getAllPlugins()
            .filter({ $0.name != PREBID_MOBILE_RENDERER_NAME })
            .map { $0.jsonDictionary() }
    }
    
    private func getPluginRenderer(for key: String) -> PrebidMobilePluginRenderer? {
        registry.active.first { $0.name == key }
    }
}
