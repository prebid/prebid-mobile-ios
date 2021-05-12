//
//  MPVASTVerification.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTModel.h"
#import "MPVASTJavaScriptResource.h"
#import "MPVASTTrackingEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Viewability verification resource.
 */
@interface MPVASTVerification : MPVASTModel
/**
 Viewability vendor
 */
@property (nonatomic, copy, readonly) NSString *vendor;

/**
 Javascript resource URL.
 */
@property (nonatomic, readonly) MPVASTJavaScriptResource *javascriptResource;

/**
 Optional verification parameters string.
 */
@property (nonatomic, nullable, copy, readonly) NSString *verificationParameters;

/**
 Optional tracking events related to verification.
 */
@property (nonatomic, nullable, readonly) NSDictionary<NSString *, NSArray<MPVASTTrackingEvent *> *> *trackingEvents;

@end

NS_ASSUME_NONNULL_END
