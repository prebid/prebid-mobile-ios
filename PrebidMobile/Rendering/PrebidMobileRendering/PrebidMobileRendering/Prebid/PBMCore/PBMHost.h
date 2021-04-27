//
//  PBMHost.h
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PBMPrebidHost) {
    PBMPrebidHost_Appnexus,
    PBMPrebidHost_Rubicon,
    PBMPrebidHost_Custom,
};

NS_ASSUME_NONNULL_BEGIN

@interface PBMHost : NSObject

@property (nonatomic, strong, class, readonly) PBMHost *shared;

- (void)setHostURL:(NSString *)hostURL;
- (nullable NSString *)getHostURL:(PBMPrebidHost)host error:(NSError* _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(getHostURL(host:));
- (BOOL)verifyUrl:(nullable NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
