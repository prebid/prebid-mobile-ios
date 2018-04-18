//
//  PBVPrebidSDKValidator.h
//  PrebidMobileValidator
//
//  Created by Wei Zhang on 4/17/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#ifndef PBVPrebidSDKValidator_h
#define PBVPrebidSDKValidator_h
#import <UIKit/UIKit.h>
@protocol PBVPrebidSDKValidatorDelegate
@required
- (void) testDidPass;
@required
- (void) testDidFail;
@end

@interface PBVPrebidSDKValidator: NSObject
@property id <PBVPrebidSDKValidatorDelegate> delegate;

- (UIViewController *) getViewController;
- (void)startTest;

@end


#endif /* PBVPrebidSDKValidator_h */
