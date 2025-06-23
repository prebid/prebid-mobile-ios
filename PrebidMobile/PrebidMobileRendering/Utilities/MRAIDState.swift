//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

@objc(PBMMRAIDState)
@_spi(PBMInternal) public
class MRAIDState: NSObject, RawRepresentable {
    public typealias RawValue = String
    
    @objc public var rawValue: String
    
    public required init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    @objc public static let notEnabled      = MRAIDState(rawValue: "not_enabled")
    @objc public static let defaultState    = MRAIDState(rawValue: "default")
    @objc public static let expanded        = MRAIDState(rawValue: "expanded")
    @objc public static let hidden          = MRAIDState(rawValue: "hidden")
    @objc public static let loading         = MRAIDState(rawValue: "loading")
    @objc public static let resized         = MRAIDState(rawValue: "resized")
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MRAIDState else {
            return false
        }
        
        return rawValue == other.rawValue
    }
    
    public override var description: String {
        rawValue
    }
    
    public override var debugDescription: String {
        rawValue
    }
}
