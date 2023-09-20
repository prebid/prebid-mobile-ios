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

#import "PBMTransactionFactory.h"

#import "PBMDisplayTransactionFactory.h"
#import "PBMVastTransactionFactory.h"
#import "PBMTransaction.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#import "PBMMacros.h"

@interface PBMTransactionFactory()

@property (nonatomic, strong, readonly, nonnull) Bid *bid;
@property (nonatomic, strong, readonly, nonnull) AdUnitConfig *adConfiguration;
@property (nonatomic, strong, readonly, nonnull) id<PrebidServerConnectionProtocol> connection;

// NOTE: need to call the completion callback only in the main thread
// use onFinishedWithTransaction
@property (nonatomic, copy, readonly, nonnull) PBMTransactionFactoryCallback callback;

@property (nonatomic, strong, nullable) NSObject *currentFactory;

// Computed properties:
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly, nonnull) PBMTransactionFactoryCallback callbackForProperFactory;

@end



@implementation PBMTransactionFactory

// MARK: - Public API

- (instancetype)initWithBid:(Bid *)bid
            adConfiguration:(AdUnitConfig *)adConfiguration
                 connection:(id<PrebidServerConnectionProtocol>)connection
                   callback:(PBMTransactionFactoryCallback)callback
{
    if (!(self = [super init])) {
        return nil;
    }
    _bid = bid;
    _adConfiguration = adConfiguration;
    _connection = connection;
    _callback = [callback copy];
    return self;
}

- (BOOL)loadWithAdMarkup:(NSString *)adMarkup {
    if (self.isLoading) {
        return NO;
    }
    
    if ([adMarkup containsString:@"<VAST"]) {
        return [self loadVASTTransaction:adMarkup];
    } else {
        return [self loadHTMLTransaction:adMarkup];
    }
}

// MARK: - Private Helpers

- (BOOL)isLoading {
    return (self.currentFactory != nil);
}

- (BOOL)loadHTMLTransaction:(NSString *)adMarkup {
    PBMDisplayTransactionFactory * const factory = [[PBMDisplayTransactionFactory alloc] initWithBid:self.bid
                                                                                     adConfiguration:self.adConfiguration
                                                                                          connection:self.connection
                                                                                            callback:self.callbackForProperFactory];
    self.currentFactory = factory;
    return [factory loadWithAdMarkup:adMarkup];
}

- (BOOL)loadVASTTransaction:(NSString *)adMarkup {
    PBMVastTransactionFactory * const factory = [[PBMVastTransactionFactory alloc] initWithBid:self.bid
                                                                                    connection:self.connection
                                                                               adConfiguration:self.adConfiguration.adConfiguration
                                                                                      callback:self.callbackForProperFactory];
    self.currentFactory = factory;
    return [factory loadWithAdMarkup:adMarkup];
}

- (PBMTransactionFactoryCallback)callbackForProperFactory {
    @weakify(self);
    return ^(PBMTransaction * _Nullable transaction, NSError * _Nullable error) {
        @strongify(self);
        if (!self) { return; }
        
        [self onFinishedWithTransaction:transaction error:error];
    };
}

- (void)onFinishedWithTransaction:(PBMTransaction *)transaction error:(NSError *)error {
    self.currentFactory = nil;
    self.callback(transaction, error);
}

@end
