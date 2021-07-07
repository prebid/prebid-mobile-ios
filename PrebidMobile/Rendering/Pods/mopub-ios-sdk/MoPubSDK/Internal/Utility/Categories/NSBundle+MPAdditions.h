//
//  NSBundle+MPAdditions.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

@interface NSBundle (MPAdditions)

/**
 Retrieves the bundle that contains the MoPubSDK resources.
 @param aClass MoPub class. Typically will be self.class.
 @returns The bundle containing the MoPubSDK resources.
 */
+ (NSBundle *)resourceBundleForClass:(Class)aClass;

/**
 The resource bundle of MoPub SDK.
 */
+ (NSBundle *)mopubResourceBundle;

@end
