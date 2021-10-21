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

@class PBMAbstractCreative;

NS_ASSUME_NONNULL_BEGIN
@protocol PBMCreativeViewDelegate <NSObject>
- (void)creativeDidComplete:(PBMAbstractCreative *)creative;
- (void)creativeDidDisplay:(PBMAbstractCreative *)creative;
- (void)creativeWasClicked:(PBMAbstractCreative *)creative;
- (void)creativeViewWasClicked:(PBMAbstractCreative *)creative;
- (void)creativeClickthroughDidClose:(PBMAbstractCreative *)creative;
- (void)creativeInterstitialDidClose:(PBMAbstractCreative *)creative;
- (void)creativeInterstitialDidLeaveApp:(PBMAbstractCreative *)creative;
- (void)creativeFullScreenDidFinish:(PBMAbstractCreative *)creative;

// MRAID Only
- (void)creativeReadyToReimplant:(PBMAbstractCreative *)creative;
- (void)creativeMraidDidCollapse:(PBMAbstractCreative *)creative;
- (void)creativeMraidDidExpand:(PBMAbstractCreative *)creative;

@optional
// Video specific method
- (void)videoCreativeDidComplete:(PBMAbstractCreative *)creative;
- (void)videoWasMuted:(PBMAbstractCreative *)creative;
- (void)videoWasUnmuted:(PBMAbstractCreative *)creative;
@end
NS_ASSUME_NONNULL_END
