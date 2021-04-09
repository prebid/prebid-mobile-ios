//
//  OXABidRequester.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABidRequester.h"
#import "OXABidResponseTransformer.h"
#import "OXABidResponse+Internal.h"
#import "OXAAdUnitConfig.h"
#import "OXAAdUnitConfig+Internal.h"
#import "OXAError.h"
#import "OXAORTB.h"
#import "OXAPrebidParameterBuilder.h"
#import "OXASDKConfiguration.h"
#import "OXASDKConfiguration+InternalState.h"
#import "OXATargeting.h"
#import "OXMParameterBuilderService.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMServerResponse.h"

#import "OXMMacros.h"

@interface OXABidRequester ()

@property (nonatomic, strong, nonnull, readonly) id<OXMServerConnectionProtocol> connection;
@property (nonatomic, strong, nonnull, readonly) OXASDKConfiguration *sdkConfiguration;
@property (nonatomic, strong, nonnull, readonly) OXATargeting *targeting;
@property (nonatomic, strong, nonnull, readonly) OXAAdUnitConfig *adUnitConfiguration;

@property (nonatomic, copy, nullable) void (^completion)(OXABidResponse *, NSError *);

@end

@implementation OXABidRequester

- (instancetype)initWithConnection:(id<OXMServerConnectionProtocol>)connection
                  sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                         targeting:(OXATargeting *)targeting
               adUnitConfiguration:(OXAAdUnitConfig *)adUnitConfiguration {
    if (!(self = [super init])) {
        return nil;
    }
    _connection = connection;
    _sdkConfiguration = sdkConfiguration;
    _targeting = targeting;
    _adUnitConfiguration = adUnitConfiguration;
    return self;
}

- (void)requestBidsWithCompletion:(void (^)(OXABidResponse *, NSError *))completion {
    NSError * const setupError = [self findErrorInSettings];
    if (setupError) {
        completion(nil, setupError);
        return;
    }
    
    if (self.completion) {
        completion(nil, [OXAError requestInProgress]);
        return;
    }
    
    self.completion = completion ?: ^(OXABidResponse *r, NSError *e) {};
    
    NSString * const requestString = [self getRTBRequest];
    
    NSLock * const timeoutLock = self.sdkConfiguration.bidRequestTimeoutLock;
   
    [timeoutLock lock];
    
    NSString * const requestServerURL       = self.sdkConfiguration.serverURL;
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
                 callback:^(OXMServerResponse * _Nonnull serverResponse) {
        @strongify(self);
        if (!self) {
            return;
        }
        
        void (^ const completion)(OXABidResponse *, NSError *) = self.completion;
        self.completion = nil;
        if (serverResponse.error) {
            OXMLogInfo(@"Bid Request Error: %@", [serverResponse.error localizedDescription]);
            completion(nil, serverResponse.error);
            return;
        }
        
        OXMLogInfo(@"Bid Response: %@", [[NSString alloc] initWithData:serverResponse.rawData encoding:NSUTF8StringEncoding]);
        
        NSError *trasformationError = nil;
        OXABidResponse * const bidResponse = [OXABidResponseTransformer transformResponse:serverResponse error:&trasformationError];
        
        if (bidResponse && !trasformationError) {
            NSNumber * const tmaxrequest = bidResponse.rawResponse.ext.tmaxrequest;
            if (tmaxrequest) {
                NSDate * const responseDate = [NSDate date];

                const NSTimeInterval bidResponseTimeout = tmaxrequest.doubleValue / 1000.0;
                const NSTimeInterval remoteTimeout = ([responseDate timeIntervalSinceDate:requestDate]
                                                      + bidResponseTimeout
                                                      + 0.2);
                [timeoutLock lock];
                NSString * const currentServerURL = self.sdkConfiguration.serverURL;
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
    
    OXAPrebidParameterBuilder * const
    prebidParamsBuilder = [[OXAPrebidParameterBuilder alloc] initWithAdConfiguration:self.adUnitConfiguration
                                                                    sdkConfiguration:self.sdkConfiguration
                                                                           targeting:self.targeting
                                                                    userAgentService:self.connection.userAgentService];
    
    NSDictionary<NSString *, NSString *> * const
    params = [OXMParameterBuilderService buildParamsDictWithAdConfiguration:self.adUnitConfiguration.adConfiguration
                                                     extraParameterBuilders:@[prebidParamsBuilder]];
        
    return params[@"openrtb"];
}

- (NSError *)findErrorInSettings {
    if (self.adUnitConfiguration.adSize) {
        if ([self isInvalidSize:self.adUnitConfiguration.adSize]) {
            return [OXAError invalidSize];
        }
    }
    if (self.adUnitConfiguration.additionalSizes) {
        for (NSValue *nextSize in self.adUnitConfiguration.additionalSizes) {
            if ([self isInvalidSize:nextSize]) {
                return [OXAError invalidSize];
            }
        }
    }
    if ([self isInvalidID:self.adUnitConfiguration.configId]) {
        return [OXAError invalidConfigId];
    }
    if ([self isInvalidID:self.sdkConfiguration.accountID]) {
        return [OXAError invalidAccountId];
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
