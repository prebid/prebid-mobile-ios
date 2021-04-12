//
//  OXMModalAnimator+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMModalAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXMModalAnimator ()

@property (nonatomic, weak) OXMModalPresentationController *modalPresentationController;

@property (nonatomic, assign) CGRect frameOfPresentedView;
@property (nonatomic, assign) BOOL isPresented;

@end

NS_ASSUME_NONNULL_END
