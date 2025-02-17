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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PBMInterstitialAdLoader;
@class InterstitialController;
@protocol InterstitialEventHandlerProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMInterstitialAdLoaderDelegate <NSObject>

@required

// Loading callbacks
- (void)interstitialAdLoader:(PBMInterstitialAdLoader *)interstitialAdLoader
                    loadedAd:(void (^)(UIViewController * _Nullable))showBlock
                isReadyBlock:(BOOL (^)(void))isReadyBlock;

// Hook to insert interaction delegate
- (void)interstitialAdLoader:(PBMInterstitialAdLoader *)interstitialAdLoader
createdInterstitialController:(InterstitialController *)interstitialController;

@end

NS_ASSUME_NONNULL_END
