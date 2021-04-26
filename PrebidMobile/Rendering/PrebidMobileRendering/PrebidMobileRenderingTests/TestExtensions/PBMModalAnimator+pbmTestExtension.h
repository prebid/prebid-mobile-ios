//
//  OXMModalAnimator+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMModalAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMModalAnimator ()

@property (nonatomic, weak) PBMModalPresentationController *modalPresentationController;

@property (nonatomic, assign) CGRect frameOfPresentedView;
@property (nonatomic, assign) BOOL isPresented;

@end

NS_ASSUME_NONNULL_END
