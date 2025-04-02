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


// Do not use `@testable import` here so that we get a compiler error if a model object is not `open`
import PrebidMobile

class CustomAdConfiguration: PBMORTBAdConfiguration {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomBidExt: PBMORTBBidExt {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomBidExtPrebid: PBMORTBBidExtPrebid {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomBidExtPrebidCache: PBMORTBBidExtPrebidCache {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomBidExtPrebidCacheBids: PBMORTBBidExtPrebidCacheBids {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomBidExtSkadn: PBMORTBBidExtSkadn {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomBidExtSkadnSKOverlay: PBMORTBBidExtSkadnSKOverlay {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomBidResponseExt: PBMORTBBidResponseExt {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomBidResponseExtPrebid: PBMORTBBidResponseExtPrebid {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomExtPrebidEvents: PBMORTBExtPrebidEvents {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomExtPrebidPassthrough: PBMORTBExtPrebidPassthrough {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomRewardedClose: PBMORTBRewardedClose {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomRewardedCompletion: PBMORTBRewardedCompletion {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomRewardedCompletionBanner: PBMORTBRewardedCompletionBanner {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomRewardedCompletionVideo: PBMORTBRewardedCompletionVideo {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomRewardedCompletionVideoEndcard: PBMORTBRewardedCompletionVideoEndcard {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomRewardedConfiguration: PBMORTBRewardedConfiguration {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomRewardedReward: PBMORTBRewardedReward {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomSDKConfiguration: PBMORTBSDKConfiguration {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

class CustomSkadnFidelity: PBMORTBSkadnFidelity {
    override init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        super.toJsonDictionary()
    }
}

func registerCustomClasses() {
    PBMCustomModelObjects.registerCustomType(CustomAdConfiguration.self)
    PBMCustomModelObjects.registerCustomType(CustomBidExt.self)
    PBMCustomModelObjects.registerCustomType(CustomBidExtPrebid.self)
    PBMCustomModelObjects.registerCustomType(CustomBidExtPrebidCache.self)
    PBMCustomModelObjects.registerCustomType(CustomBidExtPrebidCacheBids.self)
    PBMCustomModelObjects.registerCustomType(CustomBidExtSkadn.self)
    PBMCustomModelObjects.registerCustomType(CustomBidExtSkadnSKOverlay.self)
    PBMCustomModelObjects.registerCustomType(CustomBidResponseExt.self)
    PBMCustomModelObjects.registerCustomType(CustomBidResponseExtPrebid.self)
    PBMCustomModelObjects.registerCustomType(CustomExtPrebidEvents.self)
    PBMCustomModelObjects.registerCustomType(CustomExtPrebidPassthrough.self)
    PBMCustomModelObjects.registerCustomType(CustomRewardedClose.self)
    PBMCustomModelObjects.registerCustomType(CustomRewardedCompletion.self)
    PBMCustomModelObjects.registerCustomType(CustomRewardedCompletionBanner.self)
    PBMCustomModelObjects.registerCustomType(CustomRewardedCompletionVideo.self)
    PBMCustomModelObjects.registerCustomType(CustomRewardedCompletionVideoEndcard.self)
    PBMCustomModelObjects.registerCustomType(CustomRewardedConfiguration.self)
    PBMCustomModelObjects.registerCustomType(CustomRewardedReward.self)
    PBMCustomModelObjects.registerCustomType(CustomSDKConfiguration.self)
    PBMCustomModelObjects.registerCustomType(CustomSkadnFidelity.self)
}

func unregisterCustomClasses() {
    PBMCustomModelObjects.unregisterCustomType(CustomAdConfiguration.self)
    PBMCustomModelObjects.unregisterCustomType(CustomBidExt.self)
    PBMCustomModelObjects.unregisterCustomType(CustomBidExtPrebid.self)
    PBMCustomModelObjects.unregisterCustomType(CustomBidExtPrebidCache.self)
    PBMCustomModelObjects.unregisterCustomType(CustomBidExtPrebidCacheBids.self)
    PBMCustomModelObjects.unregisterCustomType(CustomBidExtSkadn.self)
    PBMCustomModelObjects.unregisterCustomType(CustomBidExtSkadnSKOverlay.self)
    PBMCustomModelObjects.unregisterCustomType(CustomBidResponseExt.self)
    PBMCustomModelObjects.unregisterCustomType(CustomBidResponseExtPrebid.self)
    PBMCustomModelObjects.unregisterCustomType(CustomExtPrebidEvents.self)
    PBMCustomModelObjects.unregisterCustomType(CustomExtPrebidPassthrough.self)
    PBMCustomModelObjects.unregisterCustomType(CustomRewardedClose.self)
    PBMCustomModelObjects.unregisterCustomType(CustomRewardedCompletion.self)
    PBMCustomModelObjects.unregisterCustomType(CustomRewardedCompletionBanner.self)
    PBMCustomModelObjects.unregisterCustomType(CustomRewardedCompletionVideo.self)
    PBMCustomModelObjects.unregisterCustomType(CustomRewardedCompletionVideoEndcard.self)
    PBMCustomModelObjects.unregisterCustomType(CustomRewardedConfiguration.self)
    PBMCustomModelObjects.unregisterCustomType(CustomRewardedReward.self)
    PBMCustomModelObjects.unregisterCustomType(CustomSDKConfiguration.self)
    PBMCustomModelObjects.unregisterCustomType(CustomSkadnFidelity.self)
}
