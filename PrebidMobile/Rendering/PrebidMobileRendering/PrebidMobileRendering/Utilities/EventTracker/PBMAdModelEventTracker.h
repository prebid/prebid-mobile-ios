//
//  PBMAdModelEventTracker.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMEventTrackerProtocol.h"

@class PBMCreativeModel;
@protocol PBMServerConnectionProtocol;

/**
 Implements PBMEventTrackerProtocol according to ad model received from the server.
 Tracking for ACJ/VAST implemented via making requests with particular URLs received in the ad model.
*/
NS_ASSUME_NONNULL_BEGIN
@interface PBMAdModelEventTracker : NSObject <PBMEventTrackerProtocol>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                     serverConnection:(id<PBMServerConnectionProtocol>)serverConnection NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
