//
//  PrebidRenderingConfig+TestExtension.m
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

#import "PrebidRenderingConfig+TestExtension.h"

@implementation PrebidRenderingConfig (Test)

@dynamic forcedIsViewable;

- (BOOL)forcedIsViewable {
    return [NSUserDefaults.standardUserDefaults boolForKey:@"forcedIsViewable"];
}

- (void)setForcedIsViewable:(BOOL) value {
    [NSUserDefaults.standardUserDefaults setBool:value forKey:@"forcedIsViewable"];
}


@end
