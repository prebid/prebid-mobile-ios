//
//  MPAdConversionTracker.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif
#import "MPAdConversionTracker.h"

@interface MPAdConversionTracker ()
@property (nonatomic, strong) NSURLSessionTask * task;
@end

@implementation MPAdConversionTracker

+ (MPAdConversionTracker *)sharedConversionTracker
{
    static MPAdConversionTracker *sharedConversionTracker;

    @synchronized(self)
    {
        if (!sharedConversionTracker)
            sharedConversionTracker = [[MPAdConversionTracker alloc] init];
        return sharedConversionTracker;
    }
}

- (void)reportApplicationOpenForApplicationID:(NSString *)appID
{
    // Store the application identifier.
    // MPConsentManager is responsible for triggering the conversion tracker when it has
    // determined that PII is allowed to be collected.
    [MPConversionManager setConversionAppId:appID];
}

@end
