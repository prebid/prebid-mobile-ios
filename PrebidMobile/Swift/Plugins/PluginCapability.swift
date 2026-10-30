/*   Copyright 2018-2026 Prebid.org, Inc.
 
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

/// A kind of plugin the SDK accepts. Pass one to `Prebid.register(_:as:)`.
///
/// Each capability accepts objects that implement its protocol, e.g. `renderer` accepts
/// `PrebidMobilePluginRenderer` objects. Only the SDK defines capabilities.
@objcMembers
public final class PluginCapability: NSObject {
    
    /// Plugin renderers: objects that implement `PrebidMobilePluginRenderer`.
    ///
    /// Renderers are identified by `name` alone: a renderer whose name is already registered is ignored,
    /// whatever its version.
    public static let renderer = PluginCapability(registry: Registries.renderer)
    
    /// The capability name, used in logs.
    public let name: String
    
    let registry: AnyPluginRegistry
    
    private init<Plugin>(registry: TypedPluginRegistry<Plugin>) {
        self.name = registry.typed.name
        self.registry = registry
        
        super.init()
    }
    
    public override var description: String {
        name
    }
}

/// The typed registry of each capability. The SDK reads the plugins of a capability from here, with no casts.
enum Registries {
    
    static let renderer = TypedPluginRegistry<any PrebidMobilePluginRenderer>(PluginRegistry(
        name: "renderer",
        identify: { PrebidPluginInfo(name: $0.name, version: "") }
    ))
}

/// Type-erased registry, so that `PluginCapability` and `Prebid.register(_:as:)` can take any object.
class AnyPluginRegistry {
    
    func add(_ object: AnyObject) {}
    
    func remove(_ object: AnyObject) {}
    
    func contains(_ object: AnyObject) -> Bool {
        false
    }
}

/// The only place where an object passed to `Prebid.register(_:as:)` is checked against the capability's protocol.
final class TypedPluginRegistry<Plugin>: AnyPluginRegistry {
    
    let typed: PluginRegistry<Plugin>
    
    init(_ typed: PluginRegistry<Plugin>) {
        self.typed = typed
    }
    
    override func add(_ object: AnyObject) {
        guard let plugin = object as? Plugin else {
            Log.error("[\(typed.name)] \(type(of: object)) doesn't implement the capability's protocol. It is not registered.")
            return
        }
        
        typed.add(plugin)
    }
    
    override func remove(_ object: AnyObject) {
        if let plugin = object as? Plugin {
            typed.remove(plugin)
        }
    }
    
    override func contains(_ object: AnyObject) -> Bool {
        guard let plugin = object as? Plugin else {
            return false
        }
        
        return typed.contains(plugin)
    }
}
