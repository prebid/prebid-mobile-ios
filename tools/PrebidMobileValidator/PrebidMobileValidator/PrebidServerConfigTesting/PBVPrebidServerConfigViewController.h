//
//  PBVPrebidServerConfigViewController.h
//  PrebidMobileValidator
//
//  Created by Wei Zhang on 4/12/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#ifndef PBVPrebidServerConfigViewController_h
#define PBVPrebidServerConfigViewController_h

#import <UIKit/UIKit.h>
#import "PBVPBSRequestResponseValidator.h"

@interface PBVPrebidServerConfigViewController: UITabBarController
-(instancetype)initWithValidator: (PBVPBSRequestResponseValidator *) validator;
@end

#endif /* PBVPrebidServerConfigViewController_h */
