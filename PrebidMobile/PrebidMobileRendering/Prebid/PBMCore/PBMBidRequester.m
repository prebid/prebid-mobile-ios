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

#import "PBMBidRequester.h"
#import "PBMBidResponseTransformer.h"
#import "PBMError.h"
#import "PBMORTBPrebid.h"
#import "PBMPrebidParameterBuilder.h"
#import "PBMParameterBuilderService.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMServerResponse.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

#import "PBMMacros.h"

@interface PBMBidRequester ()

@property (nonatomic, strong, nonnull, readonly) id<PBMServerConnectionProtocol> connection;
@property (nonatomic, strong, nonnull, readonly) Prebid *sdkConfiguration;
@property (nonatomic, strong, nonnull, readonly) Targeting *targeting;
@property (nonatomic, strong, nonnull, readonly) AdUnitConfig *adUnitConfiguration;

@property (nonatomic, copy, nullable) void (^completion)(BidResponse *, NSError *);

@end

@implementation PBMBidRequester

- (instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)connection
                  sdkConfiguration:(Prebid *)sdkConfiguration
                         targeting:(Targeting *)targeting
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
           
    NSError * hostURLError = nil;
    NSString * const requestServerURL = [Host.shared getHostURLWithHost:self.sdkConfiguration.prebidServerHost error:&hostURLError];
    
    if (hostURLError) {
        completion(nil, hostURLError);
        return;
    }
    
    const NSInteger rawTimeoutMS_onRead     = self.sdkConfiguration.timeoutMillis;
    NSNumber * const dynamicTimeout_onRead  = self.sdkConfiguration.timeoutMillisDynamic;
        
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
        
        if (serverResponse.statusCode == 204) {
            completion(nil, PBMError.blankResponse);
            return;
        }
        
        if (serverResponse.error) {
            PBMLogInfo(@"Bid Request Error: %@", [serverResponse.error localizedDescription]);
            completion(nil, serverResponse.error);
            return;
        }
        
        PBMLogInfo(@"Bid Response: %@", [[NSString alloc] initWithData:serverResponse.rawData encoding:NSUTF8StringEncoding]);
        
        NSError *trasformationError = nil;
        BidResponse * const _Nullable bidResponse = [PBMBidResponseTransformer transformResponse:serverResponse error:&trasformationError];
        
        if (bidResponse && !trasformationError) {
            NSNumber * const tmaxrequest = bidResponse.tmaxrequest;
            if (tmaxrequest) {
                NSDate * const responseDate = [NSDate date];

                const NSTimeInterval bidResponseTimeout = tmaxrequest.doubleValue / 1000.0;
                const NSTimeInterval remoteTimeout = ([responseDate timeIntervalSinceDate:requestDate]
                                                      + bidResponseTimeout
                                                      + 0.2);
                NSString * const currentServerURL = [Host.shared getHostURLWithHost:self.sdkConfiguration.prebidServerHost error:nil];
                if (self.sdkConfiguration.timeoutMillisDynamic == nil && [currentServerURL isEqualToString:requestServerURL]) {
                    const NSInteger rawTimeoutMS_onWrite = self.sdkConfiguration.timeoutMillis;
                    const NSTimeInterval appTimeout = rawTimeoutMS_onWrite / 1000.0;
                    const NSTimeInterval updatedTimeout = MIN(remoteTimeout, appTimeout);
                    self.sdkConfiguration.timeoutMillisDynamic = @(updatedTimeout);
                };
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
    if ([self isInvalidID:self.adUnitConfiguration.configId]) {
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
