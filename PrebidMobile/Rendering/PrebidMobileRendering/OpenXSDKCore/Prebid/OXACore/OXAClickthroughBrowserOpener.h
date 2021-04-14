//
//  OXAClickthroughBrowserOpener.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXASDKConfiguration.h"
#import "OXAURLOpenAttempterBlock.h"
#import "OXAViewControllerProvider.h"
#import "OXMAdConfiguration.h"
#import "OXMVoidBlock.h"
#import "OXMModalManager.h"
#import "OXMModalState.h"
#import "OXMOpenMeasurementSession.h"

typedef OXMOpenMeasurementSession * _Nullable (^OXAOpenMeasurementSessionProvider)(void);

NS_ASSUME_NONNULL_BEGIN

@interface OXAClickthroughBrowserOpener : NSObject

- (instancetype)initWithSDKConfiguration:(OXASDKConfiguration *)sdkConfiguration
                         adConfiguration:(nullable OXMAdConfiguration *)adConfiguration
                            modalManager:(OXMModalManager *)modalManager
                  viewControllerProvider:(OXAViewControllerProvider)viewControllerProvider
              measurementSessionProvider:(OXAOpenMeasurementSessionProvider)measurementSessionProvider
             onWillLoadURLInClickthrough:(nullable OXMVoidBlock)onWillLoadURLInClickthrough
                     onWillLeaveAppBlock:(nullable OXMVoidBlock)onWillLeaveAppBlock
               onClickthroughPoppedBlock:(nullable OXMModalStatePopHandler)onClickthroughPoppedBlock
                      onDidLeaveAppBlock:(nullable OXMModalStateAppLeavingHandler)onDidLeaveAppBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (BOOL)openURL:(NSURL *)url onClickthroughExitBlock:(nullable OXMVoidBlock)onClickthroughExitBlock;

- (OXAURLOpenAttempterBlock)asUrlOpenAttempter;

@end

NS_ASSUME_NONNULL_END
