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

/// Global singleton responsible to store plugin renderer instances
@objcMembers
public class PrebidMobilePluginRegister: NSObject {
    
    public static let shared = PrebidMobilePluginRegister()
    
    /// Default PrebidMobile SDK renderer
    public var sdkRenderer: PrebidMobilePluginRenderer {
        if let renderer = getPluginRenderer(for: PREBID_MOBILE_RENDERER_NAME) {
            return renderer
        }
        
        Log.error("SDK couldn't find \(PREBID_MOBILE_RENDERER_NAME) in plugin register. The new instance of \(PREBID_MOBILE_RENDERER_NAME) will be created.")
        return PrebidRenderer()
    }
    
    private let queue = DispatchQueue(
        label: "PrebidMobilePluginRegisterQueue",
        attributes: .concurrent
    )
    
    private var plugins = [String: PrebidMobilePluginRenderer]()
    
    private override init() {
        super.init()
    }
    
    /// Register plugin as renderer
    public func registerPlugin(_ renderer: PrebidMobilePluginRenderer) {
        let rendererName = renderer.name
        
        queue.async(flags: .barrier) { [weak self] in
            if self?.plugins[rendererName] != nil {
                Log.debug("Plugin with name \(rendererName) is already registered.")
                return
            }
            self?.plugins[rendererName] = renderer
        }
    }
    
    public func unregisterPlugin(_ renderer: PrebidMobilePluginRenderer) {
        queue.async(flags: .barrier) { [weak self] in
            self?.plugins.removeValue(forKey: renderer.name)
        }
    }
    
    /// Contains plugin
    public func containsPlugin(_ renderer: PrebidMobilePluginRenderer) -> Bool {
        queue.sync {
            plugins.contains { $0.value === renderer }
        }
    }
    
    /// Register event delegate
    public func registerEventDelegate(
        _ pluginEventDelegate: PluginEventDelegate,
        adUnitConfigFingerprint: String
    ) {
        queue.async(flags: .barrier) { [plugins] in
            plugins
                .values
                .forEach {
                    $0.registerEventDelegate?(
                        pluginEventDelegate: pluginEventDelegate,
                        adUnitConfigFingerprint: adUnitConfigFingerprint
                    )
                }
        }
    }
    
    /// Unregister event delegate
    public func unregisterEventDelegate(
        _ pluginEventDelegate: PluginEventDelegate,
        adUnitConfigFingerprint: String
    ) {
        queue.async(flags: .barrier) { [plugins] in
            plugins
                .values
                .forEach {
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
    public func getPluginForPreferredRenderer(bid: Bid) -> PrebidMobilePluginRenderer {
        guard let preferredRendererName = bid.pluginRendererName,
              let preferredPlugin = getPluginRenderer(for: preferredRendererName),
              preferredPlugin.version == bid.pluginRendererVersion
        else {
            return sdkRenderer
        }
        
        return preferredPlugin
    }
    
    public func getAllPlugins() -> [PrebidMobilePluginRenderer] {
        queue.sync {
            return plugins.isEmpty ? [] : Array(plugins.values)
        }
    }
    
    public func getAllPluginsJSONRepresentation() -> [[String: Any]] {
        return PrebidMobilePluginRegister
            .shared
            .getAllPlugins()
            .filter({ $0.name != PREBID_MOBILE_RENDERER_NAME })
            .map { $0.jsonDictionary() }
    }
    
    private func getPluginRenderer(for key: String) -> PrebidMobilePluginRenderer? {
        queue.sync { plugins[key] }
    }
}
