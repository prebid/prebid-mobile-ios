//
//  OXADFPBanner.m
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXADFPBanner.h"
#import "OXAInvocationHelper.h"


static NSNumber *classesCheckResult = nil;

@interface OXADFPBanner ()
@property (nonatomic, strong, readonly) DFPBannerView *banner;
@end



@implementation OXADFPBanner

// MARK: - Lifecycle

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _banner = [[DFPBannerView alloc] init];
    if (![_banner isKindOfClass:[UIView class]]) {
        return nil;
    }
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

- (UIView *)view {
    return self.banner;
}

// MARK: - Public (Boxed) Properties

- (void)setAdUnitID:(NSString *)adUnitID {
    [OXAInvocationHelper invokeVoidSelector:@selector(setAdUnitID:)
                                 withObject:adUnitID
                                   onTarget:self.banner
                                onException:nil];
}

- (NSString *)adUnitID {
    NSString *result = nil;
    [OXAInvocationHelper invokeClassResultSelector:@selector(adUnitID)
                                          onTarget:self.banner
                                       resultClass:[NSString class]
                                         outResult:&result
                                       onException:nil];
    return result;
}

- (void)setValidAdSizes:(NSArray<NSValue *> *)validAdSizes {
    [OXAInvocationHelper invokeVoidSelector:@selector(setValidAdSizes:)
                                 withObject:validAdSizes
                                   onTarget:self.banner
                                onException:nil];
}

- (NSArray<NSValue *> *)validAdSizes {
    __block NSArray *result = nil;
    [OXAInvocationHelper invokeClassResultSelector:@selector(validAdSizes)
                                          onTarget:self.banner
                                       resultClass:[NSArray<NSValue *> class]
                                         outResult:&result
                                       onException:nil];
    return result;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    [OXAInvocationHelper invokeVoidSelector:@selector(setRootViewController:)
                                 withObject:rootViewController
                                   onTarget:self.banner
                                onException:nil];
}

- (UIViewController *)rootViewController {
    __block UIViewController *result = nil;
    [OXAInvocationHelper invokeClassResultSelector:@selector(rootViewController)
                                          onTarget:self.banner
                                       resultClass:[UIViewController class]
                                         outResult:&result
                                       onException:nil];
    return result;
}

- (void)setDelegate:(id<GADBannerViewDelegate>)delegate {
    [OXAInvocationHelper invokeVoidSelector:@selector(setDelegate:)
                                 withObject:delegate
                                   onTarget:self.banner
                                onException:nil];
}

- (id<GADBannerViewDelegate>)delegate {
    __block id<GADBannerViewDelegate> result = nil;
    [OXAInvocationHelper invokeProtocolResultSelector:@selector(delegate)
                                             onTarget:self.banner
                                       resultProtocol:@protocol(GADBannerViewDelegate)
                                            outResult:&result
                                          onException:nil];
    return result;
}

- (void)setAppEventDelegate:(id<GADAppEventDelegate>)appEventDelegate {
    [OXAInvocationHelper invokeVoidSelector:@selector(setAppEventDelegate:)
                                 withObject:appEventDelegate
                                   onTarget:self.banner
                                onException:nil];
}

- (id<GADAppEventDelegate>)appEventDelegate {
    __block id<GADAppEventDelegate> result = nil;
    [OXAInvocationHelper invokeProtocolResultSelector:@selector(appEventDelegate)
                                             onTarget:self.banner
                                       resultProtocol:@protocol(GADAppEventDelegate)
                                            outResult:&result
                                          onException:nil];
    return result;
}

- (void)setAdSizeDelegate:(id<GADAdSizeDelegate>)adSizeDelegate {
    [OXAInvocationHelper invokeVoidSelector:@selector(setAdSizeDelegate:)
                                 withObject:adSizeDelegate
                                   onTarget:self.banner
                                onException:nil];
}

- (id<GADAdSizeDelegate>)adSizeDelegate {
    __block id<GADAdSizeDelegate> result = nil;
    [OXAInvocationHelper invokeProtocolResultSelector:@selector(adSizeDelegate)
                                             onTarget:self.banner
                                       resultProtocol:@protocol(GADAdSizeDelegate)
                                            outResult:&result
                                          onException:nil];
    return result;
}

- (void)setEnableManualImpressions:(BOOL)enableManualImpressions {
    BOOL argument[] = { enableManualImpressions };
    [OXAInvocationHelper invokeVoidSelector:@selector(setEnableManualImpressions:)
                               withArgument:argument
                                   onTarget:self.banner
                                onException:nil];
}

- (BOOL)enableManualImpressions {
    BOOL result = NO;
    __block NSValue *resultValue = nil;
    [OXAInvocationHelper invokeCResultSelector:@selector(enableManualImpressions)
                                      onTarget:self.banner
                                    resultType:@encode(BOOL)
                                      onResult:^(NSValue * _Nullable resultObj) {
        resultValue = resultObj;
    }
                                   onException:nil];
    [resultValue getValue:&result];
    return result;
}

- (void)setAdSize:(GADAdSize)adSize {
    GADAdSize argument[] = { adSize };
    [OXAInvocationHelper invokeVoidSelector:@selector(setAdSize:)
                               withArgument:argument
                                   onTarget:self.banner
                                onException:nil];
}

- (GADAdSize)adSize {
    GADAdSize result = kGADAdSizeInvalid;
    __block NSValue *resultValue = nil;
    [OXAInvocationHelper invokeCResultSelector:@selector(adSize)
                                      onTarget:self.banner
                                    resultType:@encode(GADAdSize)
                                      onResult:^(NSValue * _Nullable resultObj) {
        resultValue = resultObj;
    }
                                   onException:nil];
    if (resultValue) {
        result = GADAdSizeFromNSValue(resultValue);
    }
    return result;
}

// MARK: - Public methods

- (void)loadRequest:(OXADFPRequest *)request {
    [OXAInvocationHelper invokeVoidSelector:@selector(loadRequest:)
                                 withObject:request.boxedRequest
                                   onTarget:self.banner
                                onException:nil];
}

- (void)recordImpression {
    [OXAInvocationHelper invokeVoidSelector:@selector(recordImpression)
                                   onTarget:self.banner
                                onException:nil];
}

// MARK: - Private Helpers

+ (BOOL)findClasses {
    BOOL result = NO;
    @try {
        if (!NSClassFromString(@"DFPBannerView")) {
            return NO;
        }
        if (!NSProtocolFromString(@"GADBannerViewDelegate")) {
            return NO;
        }
        if (!NSProtocolFromString(@"GADAppEventDelegate")) {
            return NO;
        }
        if (!NSProtocolFromString(@"GADAdSizeDelegate")) {
            return NO;
        }
        Class const testClass = [DFPBannerView class];
        SEL selectors[] = {
            @selector(adUnitID),
            @selector(setAdUnitID:),
            @selector(validAdSizes),
            @selector(setValidAdSizes:),
            @selector(rootViewController),
            @selector(setRootViewController:),
            @selector(delegate),
            @selector(setDelegate:),
            @selector(appEventDelegate),
            @selector(setAppEventDelegate:),
            @selector(adSizeDelegate),
            @selector(setAdSizeDelegate:),
            @selector(enableManualImpressions),
            @selector(setEnableManualImpressions:),
            @selector(adSize),
            @selector(setAdSize:),
            @selector(loadRequest:),
            @selector(recordImpression),
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
