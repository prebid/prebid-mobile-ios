//
//  PBMGADRewardedAd.m
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMGADRewardedAd.h"
#import "PBMInvocationHelper.h"


static NSNumber *classesCheckResult = nil;

@interface PBMGADRewardedAd ()
@property (nonatomic, strong, readonly) GADRewardedAd *rewardedAd;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end



@implementation PBMGADRewardedAd

// MARK: - Lifecycle

- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
    if (!(self = [super init])) {
        return nil;
    }
    _rewardedAd = [[GADRewardedAd alloc] initWithAdUnitID:adUnitID];
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

- (NSObject *)boxedRewardedAd {
    return self.rewardedAd;
}

// MARK: - Public (Boxed) Properties

- (BOOL)isReady {
    BOOL result = NO;
    __block NSValue *resultValue = nil;
    [PBMInvocationHelper invokeCResultSelector:@selector(isReady)
                                      onTarget:self.rewardedAd
                                    resultType:@encode(BOOL)
                                      onResult:^(NSValue * _Nullable resultObj) {
        resultValue = resultObj;
    }
                                   onException:nil];
    [resultValue getValue:&result];
    return result;
}

- (void)setAdMetadataDelegate:(id<GADRewardedAdMetadataDelegate>)adMetadataDelegate {
    [PBMInvocationHelper invokeVoidSelector:@selector(setAdMetadataDelegate:)
                                 withObject:adMetadataDelegate
                                   onTarget:self.rewardedAd
                                onException:nil];
}

- (id<GADRewardedAdMetadataDelegate>)adMetadataDelegate {
    __block id<GADRewardedAdMetadataDelegate> result = nil;
    [PBMInvocationHelper invokeProtocolResultSelector:@selector(adMetadataDelegate)
                                             onTarget:self.rewardedAd
                                       resultProtocol:@protocol(GADRewardedAdMetadataDelegate)
                                            outResult:&result
                                          onException:nil];
    return result;
}

- (NSDictionary<GADAdMetadataKey,id> *)adMetadata {
    NSDictionary<GADAdMetadataKey,id> *result = nil;
    [PBMInvocationHelper invokeClassResultSelector:@selector(adMetadata)
                                          onTarget:self.rewardedAd
                                       resultClass:[NSDictionary<GADAdMetadataKey,id> class]
                                         outResult:&result
                                       onException:nil];
    return result;
}

- (NSObject *)reward {
    GADAdReward *result = nil;
    [PBMInvocationHelper invokeClassResultSelector:@selector(reward)
                                          onTarget:self.rewardedAd
                                       resultClass:[GADAdReward class]
                                         outResult:&result
                                       onException:nil];
    return result;
}

// MARK: - Public methods

- (void)loadRequest:(PBMDFPRequest *)request completionHandler:(GADRewardedAdLoadCompletionHandler)completionHandler {
    [PBMInvocationHelper invokeVoidSelector:@selector(loadRequest:completionHandler:)
                                 withObject:request.boxedRequest
                                otherObject:completionHandler
                                   onTarget:self.rewardedAd
                                onException:nil];
}

- (void)presentFromRootViewController:(UIViewController *)viewController delegate:(id<GADRewardedAdDelegate>)delegate {
    [PBMInvocationHelper invokeVoidSelector:@selector(loadRequest:completionHandler:)
                                 withObject:viewController
                                otherObject:delegate
                                   onTarget:self.rewardedAd
                                onException:nil];
}

// MARK: - Private Helpers

+ (BOOL)findClasses {
    BOOL result = NO;
    @try {
        if (!NSClassFromString(@"GADRewardedAd")) {
            return NO;
        }
        if (!NSClassFromString(@"GADAdReward")) {
            return NO;
        }
        if (!NSProtocolFromString(@"GADRewardedAdMetadataDelegate")) {
            return NO;
        }
        Class const testClass = [GADRewardedAd class];
        SEL selectors[] = {
            @selector(isReady),
            @selector(adMetadataDelegate),
            @selector(setAdMetadataDelegate:),
            @selector(adMetadata),
            @selector(reward),
            @selector(loadRequest:completionHandler:),
            @selector(presentFromRootViewController:delegate:),
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
