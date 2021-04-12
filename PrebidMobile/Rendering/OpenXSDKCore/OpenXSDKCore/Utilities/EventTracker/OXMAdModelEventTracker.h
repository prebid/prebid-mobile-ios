//
//  OXMAdModelEventTracker.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMEventTrackerProtocol.h"

@class OXMCreativeModel;
@protocol OXMServerConnectionProtocol;

/**
 Implements OXMEventTrackerProtocol according to ad model received from the server.
 Tracking for ACJ/VAST implemented via making requests with particular URLs received in the ad model.
*/
NS_ASSUME_NONNULL_BEGIN
@interface OXMAdModelEventTracker : NSObject <OXMEventTrackerProtocol>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCreativeModel:(OXMCreativeModel *)creativeModel
                     serverConnection:(id<OXMServerConnectionProtocol>)serverConnection NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
