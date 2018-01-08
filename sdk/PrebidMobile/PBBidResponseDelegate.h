/*   Copyright 2017 Prebid.org, Inc.
 
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

@class PBAdUnit;
@class PBBidResponse;

@protocol PBBidResponseDelegate <NSObject>

/**
 * didReceiveSuccessResponse delegate method that returns a successful bid response with either an active bid or no bid
 * @param bid : the BidResponse object that has the bid parameters
 */
- (void)didReceiveSuccessResponse:(nonnull NSArray<PBBidResponse *> *)bid;

/**
 * didCompleteWithError delegate method that sends the error object for the bid request failure
 * @param error : NSError object that contains the details as to why the request failed
 */
- (void)didCompleteWithError:(nonnull NSError *)error;

@end
