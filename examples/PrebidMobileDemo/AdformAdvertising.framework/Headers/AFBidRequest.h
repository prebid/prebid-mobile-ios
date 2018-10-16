//
//  AFAdRequest.h
//  AdformHeaderBidding
//
//  Created by Vladas Drejeris on 17/02/16.
//  Copyright © 2016 adform. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHBConstants.h"

@interface AFBidRequest : NSObject

/**
 Master tag id provided be Adform.
 */
@property (nonatomic, assign) NSInteger masterTagId;
/**
 Placement type for the bid.
 */
@property (nonatomic, assign) AFAdPlacementType placementType;
/**
 An array of NSValue encoded CGSize structures defining ad sizes supported by the placement.
 
 For convenience you can use 'AFAdDimension' or 'AFAdDimensionFromCGSize' functions to create NSValue objects.
 
 Example:
    \code
        adView.supportedDimmensions = @[AFAdDimension(320, 50), AFAdDimension(320, 150)];
    \endcode
 */
@property (nonatomic, strong) NSArray<NSValue *> *supportedAdSizes;
/**
 A timeout for the bid request.
 */
@property (nonatomic, assign) NSTimeInterval bidTimeOut;
/**
 Defines which adx server should be used.
 Available values: kAFAdxDomainEUR, kAFAdxDomainEUR, kAFAdxDomainDefault.
 You can also set another custom adx domain provided by Adform.
 */
@property (nonatomic, strong) NSString *adxDomain;

/**
 Specifies if GDPR is applied.
 Must be a BOOL value wraped in a NSNumber.
 Default value: nil.
 */
@property (nonatomic, strong) NSNumber *gdpr;

/**
 Specifies the GDPR consent.
 Base64 encoded string with vendor and purpose consent strings.
 Default value: nil.
 */
@property (nonatomic, strong) NSString *gdprConsent;


/**
 Unix timestamp identifying when bid was requested.
 */
@property (nonatomic, assign, readonly) NSTimeInterval requestTimestamp;


/**
 Creates a new AFBidRequest instance.
 
 @param mTag A master tag id provided to you by Adform.
 @param placementType The placement type.
 @param adSizes An array of NSValue encoded CGSize structures defining ad sizes supported by the placement.
 
 @return A newly created AFBidRequest instance.
 */
- (instancetype)initWithMasterTagId:(NSInteger )mTag
                      palcementType:(AFAdPlacementType )placementType
                   supportedAdSizes:(NSArray<NSValue *> *)adSizes;

@end
