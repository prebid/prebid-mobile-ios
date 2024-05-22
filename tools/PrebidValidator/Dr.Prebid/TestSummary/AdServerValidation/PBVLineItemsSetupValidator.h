/*
 *    Copyright 2018 Prebid.org, Inc.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

@protocol PBVLineItemsSetupValidatorDelegate
- (void) didFindPrebidKeywordsOnTheAdServerRequest;
- (void) didNotFindPrebidKeywordsOnTheAdServerRequest;
- (void) adServerRespondedWithPrebidCreative;
- (void) adServerDidNotRespondWithPrebidCreative:(NSError *) errorDetails;
@end


@interface PBVLineItemsSetupValidator: NSObject
@property id <PBVLineItemsSetupValidatorDelegate> delegate;

- (void) startTest;

- (NSObject *) getDisplayable;

- (NSString *) getAdServerResponse;

- (NSString *) getAdServerRequest;

- (NSString *) getAdServerPostData;
@end
