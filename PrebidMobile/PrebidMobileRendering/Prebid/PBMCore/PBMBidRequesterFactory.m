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

#import "PBMBidRequesterFactory.h"

#import "PBMBidRequester.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@implementation PBMBidRequesterFactory

+ (PBMBidRequesterFactoryBlock)requesterFactoryWithSingletons {
    return [self requesterFactoryWithConnection:[PrebidServerConnection shared]
                               sdkConfiguration:[Prebid shared]
                                      targeting:[Targeting shared]];
}

+ (PBMBidRequesterFactoryBlock)requesterFactoryWithConnection:(id<PrebidServerConnectionProtocol>)connection
                                             sdkConfiguration:(Prebid *)sdkConfiguration
                                                    targeting:(Targeting *)targeting
{
    return ^id<PBMBidRequesterProtocol> (AdUnitConfig * adUnitConfig) {
        return [[PBMBidRequester alloc] initWithConnection:connection
                                          sdkConfiguration:sdkConfiguration
                                                 targeting:targeting
                                       adUnitConfiguration:adUnitConfig];
    };
}

@end
