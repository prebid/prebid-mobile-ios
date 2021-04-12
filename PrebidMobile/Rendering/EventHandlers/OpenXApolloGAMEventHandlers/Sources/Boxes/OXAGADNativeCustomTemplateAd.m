//
//  OXAGADNativeCustomTemplateAd.m
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAGADNativeCustomTemplateAd.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "OXAInvocationHelper.h"


static NSNumber *classesCheckResult = nil;

@interface OXAGADNativeCustomTemplateAd ()
@property (nonatomic, strong, readonly) GADNativeCustomTemplateAd *customTemplateAd;
@end



@implementation OXAGADNativeCustomTemplateAd

- (instancetype)initWithCustomTemplateAd:(GADNativeCustomTemplateAd *)customTemplateAd {
    if (!(self = [super init])) {
        return nil;
    }
    _customTemplateAd = customTemplateAd;
    return self;
}

// MARK: - Public (own) properties

+ (BOOL)classesFound {
    if (classesCheckResult != nil) {
        return classesCheckResult.boolValue;
    }
    const BOOL classesFound = [self findClasses];
    classesCheckResult = @(classesFound);
    return classesFound;
}

- (NSObject *)boxedAd {
    return self.customTemplateAd;
}

// MARK: - Public (Boxed) Methods

- (nullable NSString *)stringForKey:(nonnull NSString *)key {
    NSString *result = nil;
    [OXAInvocationHelper invokeClassResultSelector:@selector(stringForKey:)
                                        withObject:key
                                          onTarget:self.customTemplateAd
                                       resultClass:[NSString class]
                                         outResult:&result
                                       onException:nil];
    return result;
}

// MARK: - Private Helpers

+ (BOOL)findClasses {
    BOOL result = NO;
    @try {
        if (!NSClassFromString(@"GADNativeCustomTemplateAd")) {
            return NO;
        }
        Class const testClass = [GADNativeCustomTemplateAd class];
        SEL selectors[] = {
            @selector(stringForKey:),
        };
        const size_t selectorsCount = sizeof(selectors) / sizeof(selectors[0]);
        for(size_t i = 0; i < selectorsCount; i++) {
            if (![testClass instancesRespondToSelector:selectors[i]]) {
                return NO;
            }
        }
        result = YES;
    }
    @catch(id anException) {
        result = NO;
    };
    return result;
}

@end
