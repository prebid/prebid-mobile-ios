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

/// Identity of a plugin: its `name` and `version`.
///
/// Within one capability, two plugins with equal info are the same plugin: registering the second one
/// is ignored, and unregistering either of them removes the registered one. Renderers are identified by
/// `name` alone, as they always have been.
@objcMembers
public final class PrebidPluginInfo: NSObject {
    
    /// The plugin name. Choose one specific to your integration (e.g. your domain) so it doesn't
    /// collide with other vendors.
    public let name: String
    
    /// The plugin version.
    public let version: String
    
    public init(name: String, version: String) {
        self.name = name
        self.version = version
        
        super.init()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PrebidPluginInfo else {
            return false
        }
        
        return name == other.name && version == other.version
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(version)
        return hasher.finalize()
    }
    
    /// `name/version`, or `name` alone when `version` is empty.
    public override var description: String {
        version.isEmpty ? name : "\(name)/\(version)"
    }
}
