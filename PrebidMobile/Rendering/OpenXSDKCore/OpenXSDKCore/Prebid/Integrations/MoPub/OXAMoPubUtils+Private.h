//
//  OXAMoPubUtils+Private.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenXApolloSDK/OXALocalResponseInfoCache.h>
#import "OXALocalResponseInfoCache+Internal.h"

#import "OXAMoPubUtils.h"

@class OXABid;

NS_ASSUME_NONNULL_BEGIN
@interface OXAMoPubUtils ()

/**
 Puts to ad object's localExtra the ad object (winning bid or native ad) and configId
 and populates adObject's keywords by targeting info
 @return YES on success and NO otherwise (when the passed ad has wrong type)
 */
+ (BOOL)setUpAdObject:(id<OXAMoPubAdObjectProtocol>)adObject
         withConfigId:(NSString *)configId
        targetingInfo:(NSDictionary<NSString *,NSString *> *)targetingInfo
          extraObject:(id)anObject forKey:(NSString *)aKey;

/**
 Removes an bid info from ad object's localExtra
 and prebid-specific keywords from ad object's keywords
 */
+ (void)cleanUpAdObject:(id<OXAMoPubAdObjectProtocol>)adObject;

@end

NS_ASSUME_NONNULL_END

