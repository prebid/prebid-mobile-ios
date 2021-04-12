//
//  NSBundle+MPAdditions.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MoPub.h"
#import "NSBundle+MPAdditions.h"

static NSString * const kPodsMoPubResourcesBundleName = @"MoPubResources";
static NSString * const kBundleExtension = @"bundle";

@implementation NSBundle (MPAdditions)

static NSBundle * sResourceBundle = nil;
+ (NSBundle *)resourceBundleForClass:(Class)aClass {
    // Cocoapods creates a resource bundle inside its own bundle to prevent namespace collisions. Try that first:
    NSURL * bundleURL = [[NSBundle bundleForClass:aClass] URLForResource:kPodsMoPubResourcesBundleName withExtension:kBundleExtension];
    if (bundleURL != nil) {
        NSBundle * resourceBundle = [NSBundle bundleWithURL:bundleURL];
        return resourceBundle;
    }

    // For any other situation, the bundle should simply be the same bundle as the class requesting it:
    return [NSBundle bundleForClass:aClass];
}

+ (NSBundle *)mopubResourceBundle {
    return [self resourceBundleForClass:MoPub.class];
}

@end
