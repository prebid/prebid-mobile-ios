//
//  OXMModalManagerDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OXMModalManager;

@protocol OXMModalManagerDelegate <NSObject>

- (void)modalManagerWillPresentModal;
- (void)modalManagerDidDismissModal;

@end

NS_ASSUME_NONNULL_END
