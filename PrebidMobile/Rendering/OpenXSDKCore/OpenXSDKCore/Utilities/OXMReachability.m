//
//  OXMReachability.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreFoundation/CoreFoundation.h>
#import "OXMLog.h"
#import "OXMReachability.h"

@interface OXMReachability()
@property SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, copy) OXMNetworkReachableBlock reachableBlock;
@end

@interface OXMReachability(PrivateMethod)
- (void)stopNotifier;
@end

#pragma mark - Supporting functions

// Flag used for debugging reachability status purposes only
#define kShouldPrintReachabilityFlags 0

#if kShouldPrintReachabilityFlags
static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment) {
    OXMLogInfo(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
        (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
        (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
        (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
        (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
        (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
        (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
        (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
        (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
        comment
    );
}
#endif

static OXANetworkType networkStatusForFlags(SCNetworkReachabilityFlags flags) {

#if kShouldPrintReachabilityFlags
    PrintReachabilityFlags(flags, "networkStatusForFlags");
#endif
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        // The target host is not reachable.
        return OXANetworkTypeOffline;
    }
    
    OXANetworkType returnValue = OXANetworkTypeOffline;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = OXANetworkTypeWifi;
    }
    
    if (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0 ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0) &&
        (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)  {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs
         ... and no [user] intervention is needed
         */
        returnValue = OXANetworkTypeWifi;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = OXANetworkTypeCell;
    }
    
    return returnValue;
}

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [OXMReachability class]], @"info was wrong class in ReachabilityCallback");
    
    if (networkStatusForFlags(flags) != OXANetworkTypeOffline) {
        OXMReachability* reachability = (__bridge OXMReachability *)info;
        reachability.reachableBlock(reachability);
        [reachability stopNotifier];
    }
}

@implementation OXMReachability

#pragma mark - Initialization
+ (instancetype)singleton {
    static OXMReachability *singleton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [OXMReachability reachabilityForInternetConnection];
    });
    
    return singleton;
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    
    OXMReachability* returnValue = NULL;
    
    if (reachability != NULL) {
        returnValue = [[self alloc] init];
        if (returnValue == NULL) {
            CFRelease(reachability);
        } else {
            returnValue.reachabilityRef = reachability;
        }
    }
    return returnValue;
}

+ (instancetype)reachabilityForInternetConnection {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}

- (BOOL)isNetworkReachable {
    return [self currentReachabilityStatus] != OXANetworkTypeOffline;
}

- (void)onNetworkRestored:(OXMNetworkReachableBlock)reachableBlock {
    
    self.reachableBlock = reachableBlock;
    SCNetworkReachabilityRef reachabilityRef = self.reachabilityRef;
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, &context)) {
        SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)stopNotifier {
    if (self.reachableBlock) {
        SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        self.reachableBlock = nil;
    }
}

- (void)dealloc {
    [self stopNotifier];
    
    if (self.reachabilityRef != NULL) {
        CFRelease(self.reachabilityRef);
        self.reachabilityRef = nil;
    }
}

#pragma mark - Network Flag Handling

- (OXANetworkType)currentReachabilityStatus {
    NSAssert(self.reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    OXANetworkType returnValue = OXANetworkTypeOffline;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        returnValue = networkStatusForFlags(flags);
    }
    
    return returnValue;
}

@end
