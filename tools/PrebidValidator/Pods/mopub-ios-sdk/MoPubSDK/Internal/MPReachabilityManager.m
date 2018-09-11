//
//  MPReachabilityManager.m
//  MoPubSDK
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPReachabilityManager.h"

@interface MPReachabilityManager()
@property (nonatomic, strong) MPReachability * reachability;
@end

@implementation MPReachabilityManager

#pragma mark - Initialization

+ (instancetype _Nonnull)sharedManager {
    static MPReachabilityManager * sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _reachability = [MPReachability reachabilityForInternetConnection];
    }

    return self;
}

- (void)dealloc {
    [_reachability stopNotifier];
}

#pragma mark - Properties

- (MPNetworkStatus)currentStatus {
    return self.reachability.currentReachabilityStatus;
}

#pragma mark - Monitoring

- (void)startMonitoring {
    [self.reachability startNotifier];
}

- (void)stopMonitoring {
    [self.reachability stopNotifier];
}

@end
