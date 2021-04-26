//
//  PBMMoPubUtils+Private.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PrebidMobileRendering/PBMLocalResponseInfoCache.h>
#import "PBMLocalResponseInfoCache+Internal.h"

#import "PBMMoPubUtils.h"

@class PBMBid;

NS_ASSUME_NONNULL_BEGIN
@interface PBMMoPubUtils ()

/**
 Puts to ad object's localExtra the ad object (winning bid or native ad) and configId
 and populates adObject's keywords by targeting info
 @return YES on success and NO otherwise (when the passed ad has wrong type)
 */
+ (BOOL)setUpAdObject:(id<PBMMoPubAdObjectProtocol>)adObject
         withConfigId:(NSString *)configId
        targetingInfo:(NSDictionary<NSString *,NSString *> *)targetingInfo
          extraObject:(id)anObject forKey:(NSString *)aKey;

/**
 Removes an bid info from ad object's localExtra
 and prebid-specific keywords from ad object's keywords
 */
+ (void)cleanUpAdObject:(id<PBMMoPubAdObjectProtocol>)adObject;

@end

NS_ASSUME_NONNULL_END

