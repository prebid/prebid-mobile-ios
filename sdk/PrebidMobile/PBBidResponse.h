/*   Copyright 2017 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

@interface PBBidResponse : NSObject

/**
 * the adUnitId is the adUnit identifier that the bid response corresponds to
 */
@property (nonatomic, readonly) NSString *__nullable adUnitId;

/**
 * customKeywords is a dictionary of all the response objects returned by the demand source that can be used in future
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *__nullable customKeywords;

/**
 * the time within which the bid value should be used else will expire & the developer has to fetch new value from the source
 */
@property (nonatomic, assign) NSTimeInterval timeToExpireAfter;

/**
 * initialize method is to create BidResponse Object with the hbpb, cacheId, & adUnitId.
 */
+ (nonnull instancetype)bidResponseWithAdUnitId:(nonnull NSString *)adUnitId
                              adServerTargeting:(nonnull NSDictionary<NSString *, NSString *> *)adServerTargeting;

/**
 * all the server response json objects are added as dictionary objects to the bid response object
 */
- (void)addCustomKeywordWithKey:(nonnull NSString *)key
                          value:(nonnull NSString *)value;

/**
 * method to check if the bid has expired or not. returns boolean true or false
 */
- (BOOL)isExpired;

@end
