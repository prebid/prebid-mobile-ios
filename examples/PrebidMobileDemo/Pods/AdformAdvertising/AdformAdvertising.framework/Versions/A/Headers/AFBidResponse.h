//
//  AFAdResponse.h
//  AdformHeaderBidding
//
//  Created by Vladas Drejeris on 17/02/16.
//  Copyright © 2016 adform. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Defines available bid statuses.
 
 - AFBidStatusUknown
 
 - AFBidStatusAvailable
 
 - AFBidStatusUnavailable
 */
typedef NS_ENUM(NSInteger, AFBidStatus) {
    
    /// Bid status is unknown.
    AFBidStatusUknown,
    
    /// Bid request returned a valid bid response.
    AFBidStatusAvailable,
    
    /// Bid request returned an empty or error response.
    AFBidStatusUnavailable
};

@class AFBidRequest;

@interface AFBidResponse : NSObject

/**
 Ad unit script represented in string.
 */
@property (nonatomic, strong, readonly) NSString *adUnitScriptRaw;

/**
 Ad unit script represented in base64 encoded string.
 */
@property (nonatomic, strong, readonly) NSString *adUnitScriptEncoded;

/**
 Ad unit size.
 */
@property (nonatomic, assign, readonly) CGSize adSize;

/**
 Bid price.
 */
@property (nonatomic, assign, readonly) double cpm;

/**
 Bid currency.
 */
@property (nonatomic, strong, readonly) NSString *currency;

/**
 Unix timestamp identifying when bid was requested.
 */
@property (nonatomic, assign, readonly) NSTimeInterval requestTimestamp;

/**
 Unix timestamp identifying when bid response was received.
 */
@property (nonatomic, assign, readonly) NSTimeInterval responseTimestamp;

/**
 Identifies time it took to execute bid request.
 */
@property (nonatomic, assign, readonly) NSTimeInterval timeToRespond;

/**
 Identifies bid status.
 
 @see AFBidStatus
 */
@property (nonatomic, assign, readonly) AFBidStatus status;

/**
 Message identifying bid status.
 */
@property (nonatomic, strong, readonly) NSString *statusMessage;


/**
 Original ad request that was used.
 */
@property (nonatomic, strong, readonly) AFBidRequest *bidRequest;

@end
