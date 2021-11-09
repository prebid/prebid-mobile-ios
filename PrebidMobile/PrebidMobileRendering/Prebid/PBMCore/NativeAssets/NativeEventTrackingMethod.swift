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

@objc enum NativeEventTrackingMethod : Int {
    case img                = 1 /// Image-pixel tracking - URL provided will be inserted as a 1x1 pixel at the time of the event.
    case js                 = 2 /// Javascript-based tracking - URL provided will be inserted as a js tag at the time of the event.
    
    case exchangeSpecific   = 500 /// Could include custom measurement companies such as moat, doubleverify, IAS, etc - in this case additional elements will often be passed
}
