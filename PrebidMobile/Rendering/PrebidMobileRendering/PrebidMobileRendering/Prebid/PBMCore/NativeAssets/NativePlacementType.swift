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

@objc public enum NativePlacementType : Int {
    
    case undefined              = 0
    case feedGridListing        = 1 /// feed/grid/listing/carousel.
    case atomicUnit             = 2 /// In the atomic unit of the content - IE in the article page or single image page
    case outsideCoreContent     = 3 /// Outside the core content - for example in the ads section on the right rail, as a banner-style placement near the content, etc.
    case recommendationWidget   = 4 /// Recommendation widget, most commonly presented below the article content.
    
    case exchangeSpecific       = 500 /// To be defined by the exchange.
};
