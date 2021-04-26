//
//  PBMAdRequestResponseVAST.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBMVastAbstractAd;

@interface PBMAdRequestResponseVAST : NSObject
@property (strong, atomic, nullable) NSArray<PBMVastAbstractAd *> *ads;
@end
