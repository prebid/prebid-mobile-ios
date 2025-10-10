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

class CustomAdConfiguration: ORTBAdConfiguration {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomBidExtSkadn: ORTBBidExtSkadn {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomBidExtSkadnSKOverlay: ORTBBidExtSkadnSKOverlay {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomBidResponseExt: ORTBBidResponseExt {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomBidResponseExtPrebid: ORTBBidResponseExtPrebid {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomExtPrebidEvents: ORTBExtPrebidEvents {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomExtPrebidPassthrough: ORTBExtPrebidPassthrough {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomRewardedClose: ORTBRewardedClose {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomRewardedCompletion: ORTBRewardedCompletion {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomRewardedCompletionBanner: ORTBRewardedCompletionBanner {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomRewardedCompletionVideo: ORTBRewardedCompletionVideo {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomRewardedCompletionVideoEndcard: ORTBRewardedCompletionVideoEndcard {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomRewardedConfiguration: ORTBRewardedConfiguration {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomRewardedReward: ORTBRewardedReward {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomSDKConfiguration: ORTBSDKConfiguration {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

class CustomSkadnFidelity: ORTBSkadnFidelity {
    required init(jsonDictionary: [String : Any]) {
        super.init(jsonDictionary: jsonDictionary)
    }
}

func registerCustomClasses() {
    CustomModelObjects.registerCustomType(CustomAdConfiguration.self)
    CustomModelObjects.registerCustomType(CustomBidExtSkadn.self)
    CustomModelObjects.registerCustomType(CustomBidExtSkadnSKOverlay.self)
    CustomModelObjects.registerCustomType(CustomBidResponseExt.self)
    CustomModelObjects.registerCustomType(CustomBidResponseExtPrebid.self)
    CustomModelObjects.registerCustomType(CustomExtPrebidEvents.self)
    CustomModelObjects.registerCustomType(CustomExtPrebidPassthrough.self)
    CustomModelObjects.registerCustomType(CustomRewardedClose.self)
    CustomModelObjects.registerCustomType(CustomRewardedCompletion.self)
    CustomModelObjects.registerCustomType(CustomRewardedCompletionBanner.self)
    CustomModelObjects.registerCustomType(CustomRewardedCompletionVideo.self)
    CustomModelObjects.registerCustomType(CustomRewardedCompletionVideoEndcard.self)
    CustomModelObjects.registerCustomType(CustomRewardedConfiguration.self)
    CustomModelObjects.registerCustomType(CustomRewardedReward.self)
    CustomModelObjects.registerCustomType(CustomSDKConfiguration.self)
    CustomModelObjects.registerCustomType(CustomSkadnFidelity.self)
}

func unregisterCustomClasses() {
    CustomModelObjects.unregisterCustomType(CustomAdConfiguration.self)
    CustomModelObjects.unregisterCustomType(CustomBidExtSkadn.self)
    CustomModelObjects.unregisterCustomType(CustomBidExtSkadnSKOverlay.self)
    CustomModelObjects.unregisterCustomType(CustomBidResponseExt.self)
    CustomModelObjects.unregisterCustomType(CustomBidResponseExtPrebid.self)
    CustomModelObjects.unregisterCustomType(CustomExtPrebidEvents.self)
    CustomModelObjects.unregisterCustomType(CustomExtPrebidPassthrough.self)
    CustomModelObjects.unregisterCustomType(CustomRewardedClose.self)
    CustomModelObjects.unregisterCustomType(CustomRewardedCompletion.self)
    CustomModelObjects.unregisterCustomType(CustomRewardedCompletionBanner.self)
    CustomModelObjects.unregisterCustomType(CustomRewardedCompletionVideo.self)
    CustomModelObjects.unregisterCustomType(CustomRewardedCompletionVideoEndcard.self)
    CustomModelObjects.unregisterCustomType(CustomRewardedConfiguration.self)
    CustomModelObjects.unregisterCustomType(CustomRewardedReward.self)
    CustomModelObjects.unregisterCustomType(CustomSDKConfiguration.self)
    CustomModelObjects.unregisterCustomType(CustomSkadnFidelity.self)
}
