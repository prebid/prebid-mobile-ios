//
//  PBMClickthroughBrowserOpener.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMURLOpenAttempterBlock.h"
#import "PBMViewControllerProvider.h"
#import "PBMAdConfiguration.h"
#import "PBMVoidBlock.h"
#import "PBMModalManager.h"
#import "PBMModalState.h"
#import "PBMOpenMeasurementSession.h"

@class PrebidRenderingConfig;

typedef PBMOpenMeasurementSession * _Nullable (^PBMOpenMeasurementSessionProvider)(void);

NS_ASSUME_NONNULL_BEGIN

@interface PBMClickthroughBrowserOpener : NSObject

- (instancetype)initWithSDKConfiguration:(PrebidRenderingConfig *)sdkConfiguration
                         adConfiguration:(nullable PBMAdConfiguration *)adConfiguration
                            modalManager:(PBMModalManager *)modalManager
                  viewControllerProvider:(PBMViewControllerProvider)viewControllerProvider
              measurementSessionProvider:(PBMOpenMeasurementSessionProvider)measurementSessionProvider
             onWillLoadURLInClickthrough:(nullable PBMVoidBlock)onWillLoadURLInClickthrough
                     onWillLeaveAppBlock:(nullable PBMVoidBlock)onWillLeaveAppBlock
               onClickthroughPoppedBlock:(nullable PBMModalStatePopHandler)onClickthroughPoppedBlock
                      onDidLeaveAppBlock:(nullable PBMModalStateAppLeavingHandler)onDidLeaveAppBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (BOOL)openURL:(NSURL *)url onClickthroughExitBlock:(nullable PBMVoidBlock)onClickthroughExitBlock;

- (PBMURLOpenAttempterBlock)asUrlOpenAttempter;

@end

NS_ASSUME_NONNULL_END
