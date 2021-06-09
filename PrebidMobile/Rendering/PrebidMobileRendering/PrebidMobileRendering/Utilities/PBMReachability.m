/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreFoundation/CoreFoundation.h>
#import "PBMLog.h"
#import "PBMReachability.h"

@interface PBMReachability()
@property SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, copy) PBMNetworkReachableBlock reachableBlock;
@end

@interface PBMReachability(PrivateMethod)
- (void)stopNotifier;
@end

#pragma mark - Supporting functions

// Flag used for debugging reachability status purposes only
#define kShouldPrintReachabilityFlags 0

#if kShouldPrintReachabilityFlags
static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment) {
    PBMLogInfo(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
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

static PBMNetworkType networkStatusForFlags(SCNetworkReachabilityFlags flags) {

#if kShouldPrintReachabilityFlags
    PrintReachabilityFlags(flags, "networkStatusForFlags");
#endif
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        // The target host is not reachable.
        return PBMNetworkTypeOffline;
    }
    
    PBMNetworkType returnValue = PBMNetworkTypeOffline;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = PBMNetworkTypeWifi;
    }
    
    if (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0 ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0) &&
        (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)  {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs
         ... and no [user] intervention is needed
         */
        returnValue = PBMNetworkTypeWifi;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = PBMNetworkTypeCell;
    }
    
    return returnValue;
}

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [PBMReachability class]], @"info was wrong class in ReachabilityCallback");
    
    if (networkStatusForFlags(flags) != PBMNetworkTypeOffline) {
        PBMReachability* reachability = (__bridge PBMReachability *)info;
        reachability.reachableBlock(reachability);
        [reachability stopNotifier];
    }
}

@implementation PBMReachability

#pragma mark - Initialization
+ (instancetype)singleton {
    static PBMReachability *singleton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [PBMReachability reachabilityForInternetConnection];
    });
    
    return singleton;
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    
    PBMReachability* returnValue = NULL;
    
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
    return [self currentReachabilityStatus] != PBMNetworkTypeOffline;
}

- (void)onNetworkRestored:(PBMNetworkReachableBlock)reachableBlock {
    
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

- (PBMNetworkType)currentReachabilityStatus {
    NSAssert(self.reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    PBMNetworkType returnValue = PBMNetworkTypeOffline;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        returnValue = networkStatusForFlags(flags);
    }
    
    return returnValue;
}

@end
