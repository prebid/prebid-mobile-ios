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

#import "NSObject+Prebid.h"
#import "NSString+Extension.h"
#import "NSTimer+Extension.h"
#import "PBBidManager.h"
#import "PBBidResponse.h"
#import "PBBidResponseDelegate.h"
#import "PBException.h"
#import "PBKeywordsManager.h"
#import "PBLogging.h"
#import "PBServerAdapter.h"

static NSTimeInterval const kBidExpiryTimerInterval = 30;

@interface PBBidManager ()

@property id<PBBidResponseDelegate> delegate;
- (void)saveBidResponses:(nonnull NSArray<PBBidResponse *> *)bidResponse;

@property (nonatomic, assign) NSTimeInterval topBidExpiryTime;
@property (nonatomic, strong) PBServerAdapter *demandAdapter;

@property (nonatomic, strong) NSMutableSet<PBAdUnit *> *adUnits;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray<PBBidResponse *> *> *__nullable bidsMap;

@end

#pragma mark PBBidResponseDelegate Implementation

@interface PBBidResponseDelegateImplementation : NSObject <PBBidResponseDelegate>

@end

@implementation PBBidResponseDelegateImplementation

- (void)didReceiveSuccessResponse:(nonnull NSArray<PBBidResponse *> *)bids {
    [[PBBidManager sharedInstance] saveBidResponses:bids];
}

- (void)didCompleteWithError:(nonnull NSError *)error {
    if (error) {
        PBLogDebug(@"Bid Failure: %@", [error localizedDescription]);
    }
}

@end

@implementation PBBidManager

@synthesize delegate;

static PBBidManager *sharedInstance = nil;
static dispatch_once_t onceToken;

#pragma mark Public API Methods

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance setDelegate:[[PBBidResponseDelegateImplementation alloc] init]];
    });
    return sharedInstance;
}

+ (void)resetSharedInstance {
    onceToken = 0;
    sharedInstance = nil;
}

- (void)registerAdUnits:(nonnull NSArray<PBAdUnit *> *)adUnits withAccountId:(nonnull NSString *)accountId {
    if (_adUnits == nil) {
        _adUnits = [[NSMutableSet alloc] init];
    }
    _bidsMap = [[NSMutableDictionary alloc] init];
    _demandAdapter = [[PBServerAdapter alloc] initWithAccountId:accountId];
    for (id adUnit in adUnits) {
        [self registerAdUnit:adUnit];
    }
    [self startPollingBidsExpiryTimer];
    [self requestBidsForAdUnits:adUnits];
}

- (nullable PBAdUnit *)adUnitByIdentifier:(nonnull NSString *)identifier {
    NSArray *adUnits = [_adUnits allObjects];
    for (PBAdUnit *adUnit in adUnits) {
        if ([[adUnit identifier] isEqualToString:identifier]) {
            return adUnit;
        }
    }
    return nil;
}

- (void)assertAdUnitRegistered:(NSString *)identifier {
    PBAdUnit *adUnit = [self adUnitByIdentifier:identifier];
    if (adUnit == nil) {
        // If there is no registered ad unit we can't complete the bidding
        // so throw an exception
        @throw [PBException exceptionWithName:PBAdUnitNotRegisteredException];
    }
}

- (nullable NSDictionary<NSString *, NSString *> *)keywordsForWinningBidForAdUnit:(nonnull PBAdUnit *)adUnit {
    NSArray *bids = [self getBids:adUnit];
    [self startNewAuction:adUnit];
    if (bids) {
        PBLogDebug(@"Bids available to create keywords");
        NSMutableDictionary<NSString *, NSString *> *keywords = [[NSMutableDictionary alloc] init];
        for (PBBidResponse *bidResp in bids) {
            [keywords addEntriesFromDictionary:bidResp.customKeywords];
        }
        return keywords;
    }
    PBLogDebug(@"No bid available to create keywords");
    return nil;
}

- (NSDictionary *)addPrebidParameters:(NSDictionary *)requestParameters
                         withKeywords:(NSDictionary *)keywordsPairs {
    NSDictionary *existingExtras = requestParameters[@"extras"];
    if (keywordsPairs) {
        NSMutableDictionary *mutableRequestParameters = [requestParameters mutableCopy];
        NSMutableDictionary *mutableExtras = [[NSMutableDictionary alloc] init];
        if (existingExtras) {
            mutableExtras = [existingExtras mutableCopy];
        }
        for (id key in keywordsPairs) {
            id value = [keywordsPairs objectForKey:key];
            if (value) {
                mutableExtras[key] = value;
            }
        }
        mutableRequestParameters[@"extras"] = [mutableExtras copy];
        requestParameters = [mutableRequestParameters copy];
    }
    return requestParameters;
}

- (void)attachTopBidHelperForAdUnitId:(nonnull NSString *)adUnitIdentifier
                           andTimeout:(int)timeoutInMS
                    completionHandler:(nullable void (^)(void))handler {
    [self assertAdUnitRegistered:adUnitIdentifier];
    if (timeoutInMS > kPCAttachTopBidMaxTimeoutMS) {
        timeoutInMS = kPCAttachTopBidMaxTimeoutMS;
    }
    if ([self isBidReady:adUnitIdentifier]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PBLogDebug(@"Calling completionHandler on attachTopBidWhenReady");
            handler();
        });
    } else {
        timeoutInMS = timeoutInMS - kPCAttachTopBidTimeoutIntervalMS;
        if (timeoutInMS > 0) {
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * kPCAttachTopBidTimeoutIntervalMS);
            dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                [self attachTopBidHelperForAdUnitId:adUnitIdentifier
                                         andTimeout:timeoutInMS
                                  completionHandler:handler];
            });
        } else {
            PBLogDebug(@"Attempting to attach cached bid for ad unit %@", adUnitIdentifier);
            PBLogDebug(@"Calling completionHandler on attachTopBidWhenReady");
            handler();
        }
    }
}

#pragma mark Internal Methods

- (void)registerAdUnit:(PBAdUnit *)adUnit {
    // Throw exceptions if size or demand source is not specified
    if (adUnit.adSizes == nil && adUnit.adType == PBAdUnitTypeBanner) {
        @throw [PBException exceptionWithName:PBAdUnitNoSizeException];
    }
    // Check if ad unit already exists, if so remove it
    NSMutableArray *adUnitsToRemove = [[NSMutableArray alloc] init];
    for (PBAdUnit *existingAdUnit in _adUnits) {
        if ([existingAdUnit.identifier isEqualToString:adUnit.identifier]) {
            [adUnitsToRemove addObject:existingAdUnit];
        }
    }
    for (PBAdUnit *adUnit in adUnitsToRemove) {
        [_adUnits removeObject:adUnit];
    }

    // Finish registration of ad unit by adding it to adUnits
    [_adUnits addObject:adUnit];
    PBLogDebug(@"AdUnit %@ is registered with Prebid Mobile", adUnit.identifier);
}

- (void)requestBidsForAdUnits:(NSArray<PBAdUnit *> *)adUnits {
    [_demandAdapter requestBidsWithAdUnits:adUnits withDelegate:[self delegate]];
}

- (void)startNewAuction:(PBAdUnit *)adUnit {
    if (adUnit && adUnit.identifier) {
        [adUnit generateUUID];
        [_bidsMap removeObjectForKey:adUnit.identifier];
        [self requestBidsForAdUnits:@[adUnit]];
    }
}

- (void)saveBidResponses:(NSArray <PBBidResponse *> *)bidResponses {
    if ([bidResponses count] > 0) {
        PBBidResponse *bid = (PBBidResponse *)bidResponses[0];
        [_bidsMap setObject:[bidResponses mutableCopy] forKey:bid.adUnitId];

        // TODO: if prebid server returns expiry time for bids we need to change this implementation
        NSTimeInterval timeToExpire = bid.timeToExpireAfter + [[NSDate date] timeIntervalSince1970];
        PBAdUnit *adUnit = [self adUnitByIdentifier:bid.adUnitId];
        [adUnit setTimeIntervalToExpireAllBids:timeToExpire];
    }
}

// Poll every 30 seconds to check for expired bids
- (void)startPollingBidsExpiryTimer {
    __weak PBBidManager *weakSelf = self;
    if ([[NSTimer class] respondsToSelector:@selector(pb_scheduledTimerWithTimeInterval:block:repeats:)]) {
        [NSTimer pb_scheduledTimerWithTimeInterval:kBidExpiryTimerInterval
                                             block:^{
                                                 PBBidManager *strongSelf = weakSelf;
                                                 [strongSelf checkForBidsExpired];
                                             }
                                           repeats:YES];
    }
}

- (void)checkForBidsExpired {
    if (_adUnits != nil && _adUnits.count > 0) {
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        for (PBAdUnit *adUnit in _adUnits) {
            NSMutableArray *bids = [_bidsMap objectForKey:adUnit.identifier];
            if (bids && [bids count] > 0 && [adUnit shouldExpireAllBids:currentTime]) {
                [self startNewAuction:adUnit];
            }
        }
    }
}

- (nullable NSArray<PBBidResponse *> *)getBids:(PBAdUnit *)adUnit {
    NSMutableArray *bids = [_bidsMap objectForKey:adUnit.identifier];
    if (bids && [bids count] > 0) {
        return bids;
    }
    return nil;
}

- (BOOL)isBidReady:(NSString *)identifier {
    if ([_bidsMap objectForKey:identifier] != nil &&
        [[_bidsMap objectForKey:identifier] count] > 0) {
        PBLogDebug(@"Bid is ready for ad unit with identifier %@", identifier);
        return YES;
    }
    return NO;
}

- (void)setBidOnAdObject:(NSObject *)adObject {
    [self clearBidOnAdObject:adObject];

    if (adObject.pb_identifier) {
        NSMutableArray *mutableKeywords;
        NSString *keywords = @"";
        SEL getKeywords = NSSelectorFromString(@"keywords");
        if ([adObject respondsToSelector:getKeywords]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            keywords = (NSString *)[adObject performSelector:getKeywords];
        }
        if (keywords.length) {
            mutableKeywords = [[keywords componentsSeparatedByString:@","] mutableCopy];
        }
        if (!mutableKeywords) {
            mutableKeywords = [[NSMutableArray alloc] init];
        }
        PBAdUnit *adUnit = adObject.pb_identifier;
        NSDictionary<NSString *, NSString *> *keywordsPairs = [self keywordsForWinningBidForAdUnit:adUnit];
        for (id key in keywordsPairs) {
            id value = [keywordsPairs objectForKey:key];
            if (value) {
                [mutableKeywords addObject:[NSString stringWithFormat:@"%@:%@", key, value]];
            }
        }
        if ([[mutableKeywords componentsJoinedByString:@","] length] > 4000) {
            PBLogDebug(@"Bid to MoPub is too long");
        } else {
            SEL setKeywords = NSSelectorFromString(@"setKeywords:");
            if ([adObject respondsToSelector:setKeywords]) {
                NSString *keywordsToSet = [mutableKeywords componentsJoinedByString:@","];
                [adObject performSelector:setKeywords withObject:keywordsToSet];
#pragma clang diagnostic pop
            }
        }
    } else {
        PBLogDebug(@"No bid available to pass to MoPub");
    }
}

- (void)clearBidOnAdObject:(NSObject *)adObject {
    NSString *keywordsString = @"";
    SEL getKeywords = NSSelectorFromString(@"keywords");
    if ([adObject respondsToSelector:getKeywords]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        keywordsString = (NSString *)[adObject performSelector:getKeywords];
    }
    if (keywordsString.length) {
        NSArray *keywords = [keywordsString componentsSeparatedByString:@","];
        NSMutableArray *mutableKeywords = [keywords mutableCopy];
        [keywords enumerateObjectsUsingBlock:^(NSString *keyword, NSUInteger idx, BOOL *stop) {
            for (NSString *reservedKey in [PBKeywordsManager reservedKeys]) {
                if ([keyword hasPrefix:reservedKey]) {
                    [mutableKeywords removeObject:keyword];
                    return;
                }
            }
        }];
        SEL setKeywords = NSSelectorFromString(@"setKeywords:");
        if ([adObject respondsToSelector:setKeywords]) {
            [adObject performSelector:setKeywords withObject:[mutableKeywords componentsJoinedByString:@","]];
#pragma clang diagnostic pop
        }
    }
}

@end
