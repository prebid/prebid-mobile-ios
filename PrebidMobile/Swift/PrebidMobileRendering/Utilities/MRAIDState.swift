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


class MRAIDState: NSObject, RawRepresentable {
    typealias RawValue = String
    
    var rawValue: String
    
    required init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    static let notEnabled      = MRAIDState(rawValue: "not_enabled")
    static let defaultState    = MRAIDState(rawValue: "default")
    static let expanded        = MRAIDState(rawValue: "expanded")
    static let hidden          = MRAIDState(rawValue: "hidden")
    static let loading         = MRAIDState(rawValue: "loading")
    static let resized         = MRAIDState(rawValue: "resized")
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MRAIDState else {
            return false
        }
        
        return rawValue == other.rawValue
    }
    
    override var description: String {
        rawValue
    }
    
    override var debugDescription: String {
        rawValue
    }
}
