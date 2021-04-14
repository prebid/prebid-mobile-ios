//
//  OXMAdRequestResponseVAST.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OXMVastAbstractAd;

@interface OXMAdRequestResponseVAST : NSObject
@property (strong, atomic, nullable) NSArray<OXMVastAbstractAd *> *ads;
@end
