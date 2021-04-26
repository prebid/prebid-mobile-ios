//
//  PBMNativeClickTrackingEntry.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeClickTrackerBinderBlock.h"
#import "PBMNativeAdMarkupLink.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

@class PBMNativeClickTrackingEntry;
typedef void (^PBMNativeClickHandlerBlock)(PBMNativeClickTrackingEntry *clickTrackingEntry);


// MARK: - PBMNativeClickTrackingEntry
@interface PBMNativeClickTrackingEntry : NSObject

@property (atomic, weak, nullable, readonly) UIView *trackedView;

@property (atomic, copy, nullable) NSString *url;
@property (atomic, copy, nullable) NSString *fallback;
@property (atomic, strong, nullable) NSArray<NSString *> *clicktrackers;

- (instancetype)initWithView:(UIView *)view
                 clickBinder:(PBMNativeClickTrackerBinderBlock)clickBinderBlock
                clickHandler:(PBMNativeClickHandlerBlock)clickHandlerBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
