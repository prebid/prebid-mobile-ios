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

@objc(PBMVastResourceType)
public enum VastResourceType: Int {
    case staticResource
    case iFrameResource
    case htmlResource
}

@objc(PBMVASTError)
public enum VASTError: Int {
    case parsing = 100
    case validation
    case unsupportedVersion
    case unexpectedAdType = 200
    case unexpectedCreativeType
    case unexpectedDuration
    case unexpectedSize
    case genericWrapperError = 300
    case wrapperTimeout
    case wrapperLimitReached
    case noAdsResponse
    case genericLinearError = 400
    case linearMediaNotFound
    case mediaFileTimeout
    case linearMediaUnsupported
    case mediaFilePlayback
    case genericNonLinearError = 500
    case nonLinearDimensions
    case nonLinearMediaNotFound
    case nonLinearResourceUnsupported
    case genericCompanionError = 600
    case companionDimensions
    case requiredCompanionUnavailable
    case companionMediaNotFound
    case companionResourceUnsupported
    case undefinedError = 900
}
