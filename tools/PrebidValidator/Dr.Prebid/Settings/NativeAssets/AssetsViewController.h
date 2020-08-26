//
//  AssetsViewController.h
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 8/19/20.
//  Copyright © 2020 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>
@import PrebidMobile;

NS_ASSUME_NONNULL_BEGIN

@protocol AssetsProtocol <NSObject>

@optional
-(void)sendSelectedAssets:(NSString *)assets;

- (void) sendSelectedEvents:(NSString *) events;

@end

@interface AssetsViewController : UIViewController

    @property (nonatomic,readwrite,weak) id<AssetsProtocol> delegate;

    @property (nonatomic, strong) NSString *assetType;

    @property (nonatomic, strong) NativeRequest *nativeRequest;

@end

NS_ASSUME_NONNULL_END
