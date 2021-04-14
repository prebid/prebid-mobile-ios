//
//  OXMHTMLCreative.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OXMAbstractCreative.h"
#import "OXMConstants.h"
#import "OXMCreativeFactory.h"

@class OXMMRAIDResizeProperties;

@interface OXMHTMLCreative : OXMAbstractCreative

@property (nonatomic, copy, nullable) OXMCreativeFactoryDownloadDataCompletionClosure downloadBlock;

@end
