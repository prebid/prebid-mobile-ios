//
//  PBMPrebidParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMPrebidParameterBuilder.h"

#import "PBMAdUnitConfig.h"
#import "PBMAdUnitConfig+Internal.h"
#import "PBMNativeAdConfiguration.h"
#import "PBMNativeAdConfiguration+Internal.h"
#import "PBMNativeMarkupRequestObject+Internal.h"
#import "PBMSDKConfiguration.h"
#import "PBMTargeting+Private.h"
#import "PBMORTB.h"
#import "PBMUserAgentService.h"

@interface PBMPrebidParameterBuilder ()

@property (nonatomic, strong, nonnull, readonly) PBMAdUnitConfig *adConfiguration;
@property (nonatomic, strong, nonnull, readonly) PBMSDKConfiguration *sdkConfiguration;
@property (nonatomic, strong, nonnull, readonly) PBMTargeting *targeting;
@property (nonatomic, strong, nonnull, readonly) PBMUserAgentService *userAgentService;

@end

@implementation PBMPrebidParameterBuilder

- (instancetype)initWithAdConfiguration:(PBMAdUnitConfig *)adConfiguration
                       sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                              targeting:(PBMTargeting *)targeting
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
    bidRequest.extPrebid.storedRequestID    = self.sdkConfiguration.accountID;
    bidRequest.extPrebid.dataBidders        = self.targeting.accessControlList;
    bidRequest.app.publisher.publisherID    = self.sdkConfiguration.accountID;
    
    bidRequest.app.ver          = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    bidRequest.device.pxratio   = @([UIScreen mainScreen].scale);
    bidRequest.source.tid       = [NSUUID UUID].UUIDString;
    bidRequest.device.ua        = [self.userAgentService getFullUserAgent];
    
    NSArray<PBMORTBFormat *> *formats = nil;
    const NSInteger formatsCount = (self.adConfiguration.adSize ? 1 : 0) + self.adConfiguration.additionalSizes.count;
    
    if (formatsCount > 0) {
        NSMutableArray<PBMORTBFormat *> * const newFormats = [[NSMutableArray alloc] initWithCapacity:formatsCount];
        if (self.adConfiguration.adSize) {
            [newFormats addObject:[PBMPrebidParameterBuilder ortbFormatWithSize:self.adConfiguration.adSize]];
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
    
    PBMORTBAppExtPrebid * const appExtPrebid = bidRequest.app.extPrebid;
    
    appExtPrebid.data = self.targeting.contextDataDictionary;
    
    for (PBMORTBImp *nextImp in bidRequest.imp) {
        nextImp.impID = [NSUUID UUID].UUIDString;
        nextImp.extPrebid.storedRequestID = self.adConfiguration.configId;
        nextImp.extPrebid.isRewardedInventory = self.adConfiguration.isOptIn;
        nextImp.extContextData = self.adConfiguration.contextDataDictionary;
        switch (adFormat) {
            case PBMAdFormatDisplayInternal: {
                PBMORTBBanner * const nextBanner = nextImp.banner;
                if (formats) {
                    nextBanner.format = formats;
                }
                if (self.adConfiguration.adPosition != PBMAdPosition_Undefined) {
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
                if (self.adConfiguration.adPosition != PBMAdPosition_Undefined) {
                    nextVideo.pos = @(self.adConfiguration.adPosition);
                }
                break;
            }
                
            case PBMAdFormatNativeInternal: {
                PBMORTBNative * const nextNative = nextImp.native;
                nextNative.request = [self.adConfiguration.nativeAdConfig.markupRequestObject toJsonStringWithError:nil];
                NSString * const ver = self.adConfiguration.nativeAdConfig.version;
                if (ver) {
                    nextNative.ver = ver;
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
    
    bidRequest.user.ext[@"data"] = self.targeting.userDataDictionary;
}

+ (PBMORTBFormat *)ortbFormatWithSize:(NSValue *)size {
    PBMORTBFormat * const format = [[PBMORTBFormat alloc] init];
    CGSize const cgSize = size.CGSizeValue;
    format.w = @(cgSize.width);
    format.h = @(cgSize.height);
    return format;
}

@end
