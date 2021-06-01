//
//  PrebidRenderingConfig+TestExtension.h
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrebidRenderingConfig (Test)

@property(nonatomic, assign) BOOL forcedIsViewable;

@end

NS_ASSUME_NONNULL_END
