//
//  PBMBidRequester.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBidRequester.h"
#import "PBMBidResponseTransformer.h"
#import "PBMError.h"
#import "PBMORTBPrebid.h"
#import "PBMPrebidParameterBuilder.h"
#import "PBMSDKConfiguration.h"
#import "PBMSDKConfiguration+InternalState.h"
#import "PBMTargeting.h"
#import "PBMParameterBuilderService.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMServerResponse.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

#import "PBMMacros.h"

@interface PBMBidRequester ()

@property (nonatomic, strong, nonnull, readonly) id<PBMServerConnectionProtocol> connection;
@property (nonatomic, strong, nonnull, readonly) PBMSDKConfiguration *sdkConfiguration;
@property (nonatomic, strong, nonnull, readonly) PBMTargeting *targeting;
@property (nonatomic, strong, nonnull, readonly) AdUnitConfig *adUnitConfiguration;

@property (nonatomic, copy, nullable) void (^completion)(BidResponse *, NSError *);

@end

@implementation PBMBidRequester

- (instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)connection
                  sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                         targeting:(PBMTargeting *)targeting
               adUnitConfiguration:(AdUnitConfig *)adUnitConfiguration {
    if (!(self = [super init])) {
        return nil;
    }
    _connection = connection;
    _sdkConfiguration = sdkConfiguration;
    _targeting = targeting;
    _adUnitConfiguration = adUnitConfiguration;
    return self;
}

- (void)requestBidsWithCompletion:(void (^)(BidResponse *, NSError *))completion {
    NSError * const setupError = [self findErrorInSettings];
    if (setupError) {
        completion(nil, setupError);
        return;
    }
    
    if (self.completion) {
        completion(nil, [PBMError requestInProgress]);
        return;
    }
    
    self.completion = completion ?: ^(BidResponse *r, NSError *e) {};
    
    NSString * const requestString = [self getRTBRequest];
    
    NSLock * const timeoutLock = self.sdkConfiguration.bidRequestTimeoutLock;
   
    [timeoutLock lock];
    
    NSError * hostURLError = nil;
    NSString * const requestServerURL = [PBMHost.shared getHostURL:self.sdkConfiguration.prebidServerHost error:&hostURLError];
    if (hostURLError) {
        completion(nil, hostURLError);
        return;
    }
    
    const NSInteger rawTimeoutMS_onRead     = self.sdkConfiguration.bidRequestTimeoutMillis;
    NSNumber * const dynamicTimeout_onRead  = self.sdkConfiguration.bidRequestTimeoutDynamic;
    
    [timeoutLock unlock];
    
    const NSTimeInterval postTimeout = (dynamicTimeout_onRead
                                        ? dynamicTimeout_onRead.doubleValue
                                        : (rawTimeoutMS_onRead / 1000.0));
    
    @weakify(self);
    NSDate * const requestDate = [NSDate date];
    [self.connection post:requestServerURL
                     data:[requestString dataUsingEncoding:NSUTF8StringEncoding]
                  timeout:postTimeout
                 callback:^(PBMServerResponse * _Nonnull serverResponse) {
        @strongify(self);
        if (!self) {
            return;
        }
        
        void (^ const completion)(BidResponse *, NSError *) = self.completion;
        self.completion = nil;
        if (serverResponse.error) {
            PBMLogInfo(@"Bid Request Error: %@", [serverResponse.error localizedDescription]);
            completion(nil, serverResponse.error);
            return;
        }
        
        PBMLogInfo(@"Bid Response: %@", [[NSString alloc] initWithData:serverResponse.rawData encoding:NSUTF8StringEncoding]);
        
        NSError *trasformationError = nil;
        BidResponse * const bidResponse = [PBMBidResponseTransformer transformResponse:serverResponse error:&trasformationError];
        
        if (bidResponse && !trasformationError) {
            NSNumber * const tmaxrequest = bidResponse.tmaxrequest;
            if (tmaxrequest) {
                NSDate * const responseDate = [NSDate date];

                const NSTimeInterval bidResponseTimeout = tmaxrequest.doubleValue / 1000.0;
                const NSTimeInterval remoteTimeout = ([responseDate timeIntervalSinceDate:requestDate]
                                                      + bidResponseTimeout
                                                      + 0.2);
                [timeoutLock lock];
                NSString * const currentServerURL = [PBMHost.shared getHostURL:self.sdkConfiguration.prebidServerHost error:nil];
                if (self.sdkConfiguration.bidRequestTimeoutDynamic == nil && [currentServerURL isEqualToString:requestServerURL]) {
                    const NSInteger rawTimeoutMS_onWrite = self.sdkConfiguration.bidRequestTimeoutMillis;
                    const NSTimeInterval appTimeout = rawTimeoutMS_onWrite / 1000.0;
                    const NSTimeInterval updatedTimeout = MIN(remoteTimeout, appTimeout);
                    self.sdkConfiguration.bidRequestTimeoutDynamic = @(updatedTimeout);
                };
                [timeoutLock unlock];
            }
        }
        
        completion(bidResponse, trasformationError);
    }];
}

- (NSString *)getRTBRequest {
    
    PBMPrebidParameterBuilder * const
    prebidParamsBuilder = [[PBMPrebidParameterBuilder alloc] initWithAdConfiguration:self.adUnitConfiguration
                                                                    sdkConfiguration:self.sdkConfiguration
                                                                           targeting:self.targeting
                                                                    userAgentService:self.connection.userAgentService];
    
    NSDictionary<NSString *, NSString *> * const
    params = [PBMParameterBuilderService buildParamsDictWithAdConfiguration:self.adUnitConfiguration.adConfiguration
                                                     extraParameterBuilders:@[prebidParamsBuilder]];
        
    return params[@"openrtb"];
}

- (NSError *)findErrorInSettings {
    if (!CGSizeEqualToSize(self.adUnitConfiguration.adSize, CGSizeZero)) {
        
        if ([self isInvalidSize:[NSValue valueWithCGSize:self.adUnitConfiguration.adSize]]) {
            return [PBMError invalidSize];
        }
    }
    if (self.adUnitConfiguration.additionalSizes) {
        for (NSValue *nextSize in self.adUnitConfiguration.additionalSizes) {
            if ([self isInvalidSize:nextSize]) {
                return [PBMError invalidSize];
            }
        }
    }
    if ([self isInvalidID:self.adUnitConfiguration.configID]) {
        return [PBMError invalidConfigId];
    }
    if ([self isInvalidID:self.sdkConfiguration.accountID]) {
        return [PBMError invalidAccountId];
    }
    return nil;
}

- (BOOL)isInvalidSize:(NSValue *)sizeObj {
    CGSize const size = sizeObj.CGSizeValue;
    return (size.width < 0 || size.height < 0);
}

- (BOOL)isInvalidID:(NSString *)idString {
    return (!idString || [idString isEqualToString:@""] || [[idString stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] length] == 0);
}

@end
