//
//  OXMAdRefreshOptions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

// Return results when restarting refresh timers.
typedef NS_ENUM(NSUInteger, OXMAdRefreshType) {     // For more info see: OXMAdViewManager:getRefreshOptions
    OXMAdRefreshType_StopWithRefreshDelay = 1,      // Do Not Refresh (autoRefreshDelay is nil or negative)
    OXMAdRefreshType_StopWithRefreshMax,            // AutoRefreshMax has been reached
    OXMAdRefreshType_ReloadLater,                   // Reload after given delay
};

@interface OXMAdRefreshOptions : NSObject

@property (nonatomic, assign) OXMAdRefreshType type;
@property (nonatomic, assign) NSInteger delay;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithType:(OXMAdRefreshType)type delay:(NSInteger)delay NS_DESIGNATED_INITIALIZER;

@end

