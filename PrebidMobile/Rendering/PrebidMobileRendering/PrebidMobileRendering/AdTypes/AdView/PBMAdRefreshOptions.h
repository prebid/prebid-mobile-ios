//
//  PBMAdRefreshOptions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

// Return results when restarting refresh timers.
typedef NS_ENUM(NSUInteger, PBMAdRefreshType) {     // For more info see: PBMAdViewManager:getRefreshOptions
    PBMAdRefreshType_StopWithRefreshDelay = 1,      // Do Not Refresh (autoRefreshDelay is nil or negative)
    PBMAdRefreshType_StopWithRefreshMax,            // AutoRefreshMax has been reached
    PBMAdRefreshType_ReloadLater,                   // Reload after given delay
};

@interface PBMAdRefreshOptions : NSObject

@property (nonatomic, assign) PBMAdRefreshType type;
@property (nonatomic, assign) NSInteger delay;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithType:(PBMAdRefreshType)type delay:(NSInteger)delay NS_DESIGNATED_INITIALIZER;

@end

