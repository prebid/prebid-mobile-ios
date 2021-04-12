//
//  OXANativeAdImpressionReporting.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeImpressionDetectionHandler.h"
#import "OXANativeAdMarkupEventTracker.h"
#import "OXATrackingURLVisitorBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdImpressionReporting : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (OXANativeImpressionDetectionHandler)impressionReporterWithEventTrackers:(NSArray<OXANativeAdMarkupEventTracker *> *)eventTrackers
                                                                urlVisitor:(OXATrackingURLVisitorBlock)urlVisitor;

@end

NS_ASSUME_NONNULL_END
