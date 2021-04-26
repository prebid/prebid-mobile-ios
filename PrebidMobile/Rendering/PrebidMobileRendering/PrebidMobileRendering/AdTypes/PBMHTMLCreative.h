//
//  PBMHTMLCreative.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBMAbstractCreative.h"
#import "PBMConstants.h"
#import "PBMCreativeFactory.h"

@class PBMMRAIDResizeProperties;

@interface PBMHTMLCreative : PBMAbstractCreative

@property (nonatomic, copy, nullable) PBMCreativeFactoryDownloadDataCompletionClosure downloadBlock;
                                      
@end
