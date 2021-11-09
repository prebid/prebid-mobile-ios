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

@objc enum NativeContextType : Int {
    case undefined          = 0
    case contentCentric     = 1 /// Content-centric context such as newsfeed, article, image gallery, video gallery, or similar.
    case socialCentric      = 2 /// Social-centric context such as social network feed, email, chat, or similar.
    case product            = 3 /// Product context such as product listings, details, recommendations, reviews, or similar.
    
    case exchangeSpecific   = 500 /// To be defined by the exchange.
};
