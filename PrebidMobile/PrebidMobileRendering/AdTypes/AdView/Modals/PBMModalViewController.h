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

#import "PBMModalViewControllerDelegate.h"

@class PBMAbstractCreative;
@class PBMModalState;
@class PBMModalManager;
@class PBMOpenMeasurementSession;
@class PBMInterstitialDisplayProperties;
@class PBMCloseActionManager;

@interface PBMModalViewController : UIViewController

@property (nonatomic, weak, nullable) id<PBMModalViewControllerDelegate> modalViewControllerDelegate;
@property (nonatomic, weak, nullable) PBMModalManager *modalManager;

@property (nonatomic, strong, nullable) PBMModalState *modalState;

@property (nonatomic, strong, nullable) UIView *contentView;
@property (nonatomic, readonly, nullable) UIView *displayView;
@property (nonatomic, readonly, nullable) PBMInterstitialDisplayProperties *displayProperties;
@property (nonatomic, assign, getter=isRotationEnabled) BOOL rotationEnabled;

- (void)setupState:(nonnull PBMModalState *)modalState;
- (void)creativeDisplayCompleted:(nonnull PBMAbstractCreative *)creative;

- (void)addFriendlyObstructionsToMeasurementSession:(nonnull PBMOpenMeasurementSession *)session;

- (void)configureDisplayView;

@end
