/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

enum IntegrationKind: CustomStringConvertible, CaseIterable {
    
    case gamOriginal
    case gam
    case inApp
    case adMob
    case max
    
    var description: String {
        switch self {
        case .gamOriginal:
            return "GAM (Original API)"
        case .gam:
            return "GAM"
        case .inApp:
            return "In-App"
        case .adMob:
            return "AdMob"
        case .max:
            return "MAX"
        }
    }
}
