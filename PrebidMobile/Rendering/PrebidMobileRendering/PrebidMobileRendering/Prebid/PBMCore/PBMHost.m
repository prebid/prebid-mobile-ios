//
//  PBMHost.m
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

#import "PBMError.h"
#import "PBMHost.h"

static const NSString * appnexusURL = @"https://prebid.adnxs.com/pbs/v1/openrtb2/auction";
static NSString * rubiconURL = @"https://prebid-server.rubiconproject.com/openrtb2/auction";

static PBMHost * _pbmSHostSingleton = nil;

@interface PBMHost()
@property (nonatomic, copy, nullable) NSString *prebidServerURL;
@end

@implementation PBMHost

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    return self;
}

// MARK: - Class properties

+ (PBMHost *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pbmSHostSingleton = [[PBMHost alloc] init];
    });
    return _pbmSHostSingleton;
}

- (void)setHostURL:(NSString *)hostURL {
    self.prebidServerURL = hostURL;
}

- (NSString *)getHostURL:(PBMPrebidHost)host error:(NSError* _Nullable __autoreleasing * _Nullable)error {
    switch(host) {
        case PBMPrebidHost_Appnexus:
            return [appnexusURL copy];
        case PBMPrebidHost_Rubicon:
            return [rubiconURL copy];
        case PBMPrebidHost_Custom:
            if ([self verifyUrl:self.prebidServerURL]) {
                if (error) {
                    *error = nil;
                }
                return self.prebidServerURL;
            } else {
                if (error) {
                    *error = [PBMError prebidServerURLInvalid:self.prebidServerURL];
                }
                return nil;
            }
    }
}

- (BOOL)verifyUrl:(NSString *)urlString {
    if (urlString == nil) {
        return NO;
    } else {
        const NSURL * url = [NSURL URLWithString:urlString];
        if (url == nil) {
            return NO;
        }
    }
    return YES;
}

@end
