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

@objc enum NativeEventType : Int {
    case impression         = 1     /// Impression
    case mrc50              = 2     /// Visible impression using MRC definition at 50% in view for 1 second
    case mrc100             = 3     /// 100% in view for 1 second (ie GroupM standard)
    case video50            = 4     /// Visible impression for video using MRC definition at 50% in view for 2 seconds
    
    case exchangeSpecific   = 500   /// Reserved for Exchange specific usage numbered above 500
    case omid               = 555   /// Open Measurement event
}
