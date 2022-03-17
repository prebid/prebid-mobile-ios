/*   Copyright 2018-2021 Prebid.org, Inc.

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

#import <UIKit/UIKit.h>

#import "PBMPrimaryAdRequesterProtocol.h"

@class BidResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMInterstitialAd <PBMPrimaryAdRequesterProtocol>

@required

/*!
 @abstract Return whether an interstitial is ready for display
 */
@property (nonatomic, readonly) BOOL isReady;

/*!
 @abstract PBM SDK calls this method to show the interstitial ad from the ad server SDK
 @param controller view controller to be used for presenting the interstitial ad
*/
- (void)showFromViewController:(nullable UIViewController *)controller;

@optional

/*!
  @abstract Called by PBM SDK to notify primary ad server.
 */
- (void)trackImpression;

@end

NS_ASSUME_NONNULL_END
