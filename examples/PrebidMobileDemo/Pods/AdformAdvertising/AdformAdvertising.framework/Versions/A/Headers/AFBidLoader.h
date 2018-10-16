//
//  AFBidLoader.h
//  AdformHeaderBidding
//
//  Created by Vladas Drejeris on 20/04/16.
//  Copyright © 2016 Adform. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFBidRequest, AFBidResponse;

/**
 This class is responsable for executing bid requests.
 
 It is possible to create multiple AFBidLoader instances,
 but for most cases it should be enough to use the default shared instance.
 You can access it through 'defaultLoader' class method.
 */
@interface AFBidLoader : NSObject

/**
 Returns a shared default bid loader.
 
 @return A shared instance of AFBidLoader.
 */
+ (instancetype)defaultLoader;


/**
 Request bids with bid request.
 
 @param bidRequest A bid request containing parameter used to request bids.
 @param completion A block of code called when bid request finishes.
    If sdk was unable to reach the adx server then bidResponses parameter passed to 
    block will be nil and an error containing information about what went wrong 
    will be passed to the compleation handler.
    If server was reached successfully then bidResponses parameter will contain a bid response
    and error will be nil. In this case you should check bid response 'status' property to see
    if bid is available.
 
 */
- (void)requestBids:(AFBidRequest *)bidRequest
  completionHandler:(void(^)(NSArray <AFBidResponse *> *bidResponses, NSError *error))completion;

/**
 A convenience method to request bids on default bid loader.
 
 @param bidRequest A bid request containing parameter used to request bids.
 @param completion A block of code called when bid request finishes.
    If sdk was unable to reach the adx server then bidResponses parameter passed to
    block will be nil and an error containing information about what went wrong
    will be passed to the compleation handler.
    If server was reached successfully then bidResponses parameter will contain a bid response
    and error will be nil. In this case you should check bid response 'status' property to see
    if bid is available.
 */
+ (void)requestBids:(AFBidRequest *)bidRequest
  completionHandler:(void(^)(NSArray <AFBidResponse *> *bidResponses, NSError *error))completion;

@end
