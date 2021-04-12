//
//  OXAPrebidParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAPrebidParameterBuilder.h"

#import "OXAAdUnitConfig.h"
#import "OXAAdUnitConfig+Internal.h"
#import "OXANativeAdConfiguration.h"
#import "OXANativeAdConfiguration+Internal.h"
#import "OXANativeMarkupRequestObject+Internal.h"
#import "OXASDKConfiguration.h"
#import "OXATargeting+Private.h"
#import "OXMORTB.h"
#import "OXMUserAgentService.h"

@interface OXAPrebidParameterBuilder ()

@property (nonatomic, strong, nonnull, readonly) OXAAdUnitConfig *adConfiguration;
@property (nonatomic, strong, nonnull, readonly) OXASDKConfiguration *sdkConfiguration;
@property (nonatomic, strong, nonnull, readonly) OXATargeting *targeting;
@property (nonatomic, strong, nonnull, readonly) OXMUserAgentService *userAgentService;

@end

@implementation OXAPrebidParameterBuilder

- (instancetype)initWithAdConfiguration:(OXAAdUnitConfig *)adConfiguration
                       sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                              targeting:(OXATargeting *)targeting
                       userAgentService:(OXMUserAgentService *)userAgentService
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

- (void)buildBidRequest:(nonnull OXMORTBBidRequest *)bidRequest {
    
    OXMAdFormat const adFormat = self.adConfiguration.adConfiguration.adFormat;
    BOOL const isHTML = (adFormat == OXMAdFormatDisplay);
    BOOL const isInterstitial = self.adConfiguration.isInterstitial;
    
    bidRequest.requestID = [NSUUID UUID].UUIDString;
    bidRequest.extPrebid.storedRequestID    = self.sdkConfiguration.accountID;
    bidRequest.extPrebid.dataBidders        = self.targeting.accessControlList;
    bidRequest.app.publisher.publisherID    = self.sdkConfiguration.accountID;
    
    bidRequest.app.ver          = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    bidRequest.device.pxratio   = @([UIScreen mainScreen].scale);
    bidRequest.source.tid       = [NSUUID UUID].UUIDString;
    bidRequest.device.ua        = [self.userAgentService getFullUserAgent];
    
    NSArray<OXMORTBFormat *> *formats = nil;
    const NSInteger formatsCount = (self.adConfiguration.adSize ? 1 : 0) + self.adConfiguration.additionalSizes.count;
    
    if (formatsCount > 0) {
        NSMutableArray<OXMORTBFormat *> * const newFormats = [[NSMutableArray alloc] initWithCapacity:formatsCount];
        if (self.adConfiguration.adSize) {
            [newFormats addObject:[OXAPrebidParameterBuilder ortbFormatWithSize:self.adConfiguration.adSize]];
        }
        for (NSValue *nextSize in self.adConfiguration.additionalSizes) {
            [newFormats addObject:[OXAPrebidParameterBuilder ortbFormatWithSize:nextSize]];
        }
        formats = newFormats;
    } else if (isInterstitial) {
        NSNumber * const w = bidRequest.device.w;
        NSNumber * const h = bidRequest.device.h;
        if (w && h) {
            OXMORTBFormat * const newFormat = [[OXMORTBFormat alloc] init];
            newFormat.w = w;
            newFormat.h = h;
            formats = @[newFormat];
        }
        if (self.adConfiguration.minSizePerc && isHTML) {
            const CGSize minSizePerc = self.adConfiguration.minSizePerc.CGSizeValue;
            OXMORTBDeviceExtPrebidInterstitial * const interstitial = bidRequest.device.extPrebid.interstitial;
            interstitial.minwidthperc = @(minSizePerc.width);
            interstitial.minheightperc = @(minSizePerc.height);
        }
    }
    
    OXMORTBAppExtPrebid * const appExtPrebid = bidRequest.app.extPrebid;
    
    appExtPrebid.data = self.targeting.contextDataDictionary;
    
    for (OXMORTBImp *nextImp in bidRequest.imp) {
        nextImp.impID = [NSUUID UUID].UUIDString;
        nextImp.extPrebid.storedRequestID = self.adConfiguration.configId;
        nextImp.extPrebid.isRewardedInventory = self.adConfiguration.isOptIn;
        nextImp.extContextData = self.adConfiguration.contextDataDictionary;
        switch (adFormat) {
            case OXMAdFormatDisplay: {
                OXMORTBBanner * const nextBanner = nextImp.banner;
                if (formats) {
                    nextBanner.format = formats;
                }
                if (self.adConfiguration.adPosition != OXAAdPosition_Undefined) {
                    nextBanner.pos = @(self.adConfiguration.adPosition);
                }
                break;
            }
                
            case OXMAdFormatVideo: {
                OXMORTBVideo * const nextVideo = nextImp.video;
                nextVideo.linearity = @(1); // -> linear/in-steam
                if (formats.count) {
                    OXMORTBFormat * const primarySize = (OXMORTBFormat *)formats[0];
                    nextVideo.w = primarySize.w;
                    nextVideo.h = primarySize.h;
                }
                if (self.adConfiguration.adPosition != OXAAdPosition_Undefined) {
                    nextVideo.pos = @(self.adConfiguration.adPosition);
                }
                break;
            }
                
            case OXMAdFormatNative: {
                OXMORTBNative * const nextNative = nextImp.native;
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

+ (OXMORTBFormat *)ortbFormatWithSize:(NSValue *)size {
    OXMORTBFormat * const format = [[OXMORTBFormat alloc] init];
    CGSize const cgSize = size.CGSizeValue;
    format.w = @(cgSize.width);
    format.h = @(cgSize.height);
    return format;
}

@end
