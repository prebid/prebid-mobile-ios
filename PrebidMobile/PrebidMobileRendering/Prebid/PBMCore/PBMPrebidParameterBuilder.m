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

#import "PBMPrebidParameterBuilder.h"

#import "PBMORTB.h"
#import "PBMUserAgentService.h"

#import "PBMAdViewManagerDelegate.h"
#import "PBMJsonCodable.h"

#import "PBMBaseAdUnit.h"
#import "PBMBidRequesterFactoryBlock.h"
#import "PBMWinNotifierBlock.h"

#import "PBMORTBAppContent.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

@interface PBMPrebidParameterBuilder ()

@property (nonatomic, strong, nonnull, readonly) AdUnitConfig *adConfiguration;
@property (nonatomic, strong, nonnull, readonly) Prebid *sdkConfiguration;
@property (nonatomic, strong, nonnull, readonly) Targeting *targeting;
@property (nonatomic, strong, nonnull, readonly) PBMUserAgentService *userAgentService;

@end

@implementation PBMPrebidParameterBuilder

- (instancetype)initWithAdConfiguration:(AdUnitConfig *)adConfiguration
                       sdkConfiguration:(Prebid *)sdkConfiguration
                              targeting:(Targeting *)targeting
                       userAgentService:(PBMUserAgentService *)userAgentService
{
    if (!(self = [super init])) {
        return nil;
    }
    _adConfiguration = adConfiguration;
    _sdkConfiguration = sdkConfiguration;
    _targeting = targeting;
    _userAgentService = userAgentService;
    return self;
}

- (void)buildBidRequest:(nonnull PBMORTBBidRequest *)bidRequest {
    
    PBMAdFormatInternal const adFormat = self.adConfiguration.adConfiguration.adFormat;
    BOOL const isHTML = (adFormat == PBMAdFormatDisplayInternal);
    BOOL const isInterstitial = self.adConfiguration.isInterstitial;
    
    bidRequest.requestID = [NSUUID UUID].UUIDString;
    bidRequest.extPrebid.storedRequestID        = self.sdkConfiguration.accountID;
    bidRequest.extPrebid.storedAuctionResponse  = Prebid.shared.storedAuctionResponse;
    bidRequest.extPrebid.dataBidders            = self.targeting.accessControlList;
    bidRequest.app.publisher.publisherID        = self.sdkConfiguration.accountID;
    
    bidRequest.app.ver          = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    bidRequest.device.pxratio   = @([UIScreen mainScreen].scale);
    bidRequest.source.tid       = [NSUUID UUID].UUIDString;
    bidRequest.device.ua        = [self.userAgentService getFullUserAgent];
    
    bidRequest.app.content = [self.adConfiguration getAppContent];
    bidRequest.user.ext[@"data"] = self.targeting.userDataDictionary;
    
    NSArray<PBMORTBFormat *> *formats = nil;
    const NSInteger formatsCount = (CGSizeEqualToSize(self.adConfiguration.adSize, CGSizeZero) ? 0 : 1) + self.adConfiguration.additionalSizes.count;
    
    if (formatsCount > 0) {
        NSMutableArray<PBMORTBFormat *> * const newFormats = [[NSMutableArray alloc] initWithCapacity:formatsCount];
        if (!CGSizeEqualToSize(self.adConfiguration.adSize, CGSizeZero)) {
            NSValue *value = [NSValue valueWithCGSize:self.adConfiguration.adSize];
            [newFormats addObject:[PBMPrebidParameterBuilder ortbFormatWithSize: value]];
        }
        for (NSValue *nextSize in self.adConfiguration.additionalSizes) {
            [newFormats addObject:[PBMPrebidParameterBuilder ortbFormatWithSize:nextSize]];
        }
        formats = newFormats;
    } else if (isInterstitial) {
        NSNumber * const w = bidRequest.device.w;
        NSNumber * const h = bidRequest.device.h;
        if (w && h) {
            PBMORTBFormat * const newFormat = [[PBMORTBFormat alloc] init];
            newFormat.w = w;
            newFormat.h = h;
            formats = @[newFormat];
        }
        if (self.adConfiguration.minSizePerc && isHTML) {
            const CGSize minSizePerc = self.adConfiguration.minSizePerc.CGSizeValue;
            PBMORTBDeviceExtPrebidInterstitial * const interstitial = bidRequest.device.extPrebid.interstitial;
            interstitial.minwidthperc = @(minSizePerc.width);
            interstitial.minheightperc = @(minSizePerc.height);
        }
    }
    
    NSArray<PBMORTBContentData *> *userData = [self.adConfiguration getUserData];
    if (userData) {
        bidRequest.user.data = userData;
    }
    
    PBMORTBAppExtPrebid * const appExtPrebid = bidRequest.app.extPrebid;
    appExtPrebid.data = self.targeting.contextDataDictionary;
    
    for (PBMORTBImp *nextImp in bidRequest.imp) {
        nextImp.impID = [NSUUID UUID].UUIDString;
        nextImp.extPrebid.storedRequestID = self.adConfiguration.configId;
        nextImp.extPrebid.storedAuctionResponse = Prebid.shared.storedAuctionResponse;
        nextImp.extPrebid.isRewardedInventory = self.adConfiguration.isOptIn;
        nextImp.extContextData = self.adConfiguration.contextDataDictionary.mutableCopy;
        nextImp.extContextData[@"adslot"] = [self.adConfiguration getPbAdSlot];
        switch (adFormat) {
            case PBMAdFormatDisplayInternal: {
                PBMORTBBanner * const nextBanner = nextImp.banner;
                if (formats) {
                    nextBanner.format = formats;
                }
                if (self.adConfiguration.adPosition != AdPositionUndefined) {
                    nextBanner.pos = @(self.adConfiguration.adPosition);
                }
                break;
            }
                
            case PBMAdFormatVideoInternal: {
                PBMORTBVideo * const nextVideo = nextImp.video;
                nextVideo.linearity = @(1); // -> linear/in-steam
                if (formats.count) {
                    PBMORTBFormat * const primarySize = (PBMORTBFormat *)formats[0];
                    nextVideo.w = primarySize.w;
                    nextVideo.h = primarySize.h;
                }
                if (self.adConfiguration.adPosition != AdPositionUndefined) {
                    nextVideo.pos = @(self.adConfiguration.adPosition);
                }
                break;
            }
            
            default:
                break;
        }
        if (isInterstitial) {
            nextImp.instl = @(1);
        }
        if (!appExtPrebid.source) {
            appExtPrebid.source = nextImp.displaymanager;
        }
        if (!appExtPrebid.version) {
            appExtPrebid.version = nextImp.displaymanagerver;
        }
    }
}

+ (PBMORTBFormat *)ortbFormatWithSize:(NSValue *)size {
    PBMORTBFormat * const format = [[PBMORTBFormat alloc] init];
    CGSize const cgSize = size.CGSizeValue;
    format.w = @(cgSize.width);
    format.h = @(cgSize.height);
    return format;
}

@end
