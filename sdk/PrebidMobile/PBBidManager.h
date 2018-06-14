/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "PBAdUnit.h"
#import "PBHost.h"

@class PBBidResponse;

static int const kPCAttachTopBidTimeoutIntervalMS = 50;
static int const kPCAttachTopBidMaxTimeoutMS = 1500;

@interface PBBidManager : NSObject

/**
 * shared instance of the PBBidManager class
 */
+ (nonnull instancetype)sharedInstance;

#ifdef DEBUG
+ (void)resetSharedInstance;
#endif

typedef NS_ENUM(NSInteger, PBPrimaryAdServerType) {
    PBPrimaryAdServerUnknown,
    PBPrimaryAdServerDFP,
    PBPrimaryAdServerMoPub
};

/**
 * Registers all the ad units with the prebid server account id, host, and primary ad server and starts the auction for each ad unit
 */
- (void)registerAdUnits:(nonnull NSArray<PBAdUnit *> *)adUnits
          withAccountId:(nonnull NSString *)accountId
               withHost:(PBServerHost)host
     andPrimaryAdServer:(PBPrimaryAdServerType)adServer;

/**
 * Returns the ad unit for the string identifier
 */
- (nullable PBAdUnit *)adUnitByIdentifier:(nonnull NSString *)identifier;

/**
 * asserts that the AdUnit is registered before the bidding takes place
 * @param identifier : the ad unit identity specified by the developer
 */
- (void)assertAdUnitRegistered:(nonnull NSString *)identifier;

/**
 * Returns the keywords pairs for the top bid of an adUnit
 */
- (nullable NSDictionary<NSString *, NSString *> *)keywordsForWinningBidForAdUnit:(nonnull PBAdUnit *)adUnit;

- (nonnull NSDictionary *)addPrebidParameters:(nonnull NSDictionary *)requestParameters
                                 withKeywords:(nonnull NSDictionary *)keywordsPairs;

/**
 * helper method for ad server adapter attachTopBid method
 * @param adUnitIdentifier : the ad unit id
 * @param timeoutInMS : the timeout in milliseconds to wait for a bid
 * @param handler : the code to be executed upon timeout or successful bid
 */
- (void)attachTopBidHelperForAdUnitId:(nonnull NSString *)adUnitIdentifier
                           andTimeout:(int)timeoutInMS
                    completionHandler:(nullable void (^)(void))handler;

- (void)setBidOnAdObject:(nonnull NSObject *)adObject;
- (void)clearBidOnAdObject:(nonnull NSObject *)adObject;

-(void) loadOnSecureConnection:(BOOL) secureConnection;

@end
