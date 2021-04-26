//
//  PBMNativeAdImpressionReporting.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeImpressionDetectionHandler.h"
#import "PBMNativeAdMarkupEventTracker.h"
#import "PBMTrackingURLVisitorBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdImpressionReporting : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (PBMNativeImpressionDetectionHandler)impressionReporterWithEventTrackers:(NSArray<PBMNativeAdMarkupEventTracker *> *)eventTrackers
                                                                urlVisitor:(PBMTrackingURLVisitorBlock)urlVisitor;

@end

NS_ASSUME_NONNULL_END
