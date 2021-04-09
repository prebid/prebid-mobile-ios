//
//  OXANativeClickTrackingEntry.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeClickTrackerBinderBlock.h"
#import "OXANativeAdMarkupLink.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

@class OXANativeClickTrackingEntry;
typedef void (^OXANativeClickHandlerBlock)(OXANativeClickTrackingEntry *clickTrackingEntry);


// MARK: - OXANativeClickTrackingEntry
@interface OXANativeClickTrackingEntry : NSObject

@property (atomic, weak, nullable, readonly) UIView *trackedView;

@property (atomic, copy, nullable) NSString *url;
@property (atomic, copy, nullable) NSString *fallback;
@property (atomic, strong, nullable) NSArray<NSString *> *clicktrackers;

- (instancetype)initWithView:(UIView *)view
                 clickBinder:(OXANativeClickTrackerBinderBlock)clickBinderBlock
                clickHandler:(OXANativeClickHandlerBlock)clickHandlerBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
