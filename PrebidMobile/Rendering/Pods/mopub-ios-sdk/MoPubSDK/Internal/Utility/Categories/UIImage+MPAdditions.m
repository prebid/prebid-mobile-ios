//
//  UIImage+MPAdditions.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "NSBundle+MPAdditions.h"
#import "UIImage+MPAdditions.h"

MPImageAsset const kMPImageAssetCloseButton = @"MPCloseButton";
MPImageAsset const kMPImageAssetSkipButton = @"MPSkipButton";

@implementation UIImage (MPAdditions)

+ (UIImage *)imageForAsset:(MPImageAsset)asset {
    return [UIImage imageNamed:asset inBundle:NSBundle.mopubResourceBundle compatibleWithTraitCollection:nil];
}

@end
