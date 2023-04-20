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

#import "PBMVastTransactionFactory.h"
#import "PBMAdLoadManagerVAST.h"
#import "PBMMacros.h"

@interface PBMVastTransactionFactory() <PBMAdLoadManagerDelegate>

@property (nonatomic, strong, readonly, nonnull) id<PrebidServerConnectionProtocol> connection;
@property (nonatomic, strong, readonly, nonnull) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong, readonly, nonnull) Bid *bid;

// NOTE: need to call the completion callback only in the main thread
// use onFinishedWithTransaction
@property (nonatomic, copy, readonly, nonnull) PBMTransactionFactoryCallback callback;

@property (nonatomic, strong, nullable) PBMAdLoadManagerVAST *vastLoadManager;
@property (nonatomic, readonly) BOOL isLoading;

@end


@implementation PBMVastTransactionFactory

// MARK: - Public API

- (instancetype)initWithBid:(Bid *)bid
                 connection:(id<PrebidServerConnectionProtocol>)connection
            adConfiguration:(PBMAdConfiguration *)adConfiguration
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
    
    return [self loadVASTTransaction:adMarkup];
}

// MARK: - PBMAdLoadManagerDelegate protocol

- (void)loadManager:(id<PBMAdLoadManagerProtocol>)loadManager didLoadTransaction:(PBMTransaction *)transaction {
    [self onFinishedWithTransaction:transaction error:nil];
}

- (void)loadManager:(id<PBMAdLoadManagerProtocol>)loadManager failedToLoadTransaction:(PBMTransaction *)transaction
              error:(NSError *)error
{
    [self onFinishedWithTransaction:nil error:error];
}

// MARK: - Private Helpers

- (BOOL)isLoading {
    return (self.vastLoadManager != nil);
}

- (BOOL)loadVASTTransaction:(NSString *)adMarkup {
    self.vastLoadManager = [[PBMAdLoadManagerVAST alloc] initWithBid:self.bid
                                                          connection:self.connection
                                                     adConfiguration:self.adConfiguration];
    self.vastLoadManager.adLoadManagerDelegate = self;
    [self.vastLoadManager loadFromString:adMarkup];
    return YES;
}

- (void)onFinishedWithTransaction:(PBMTransaction *)transaction error:(NSError *)error {
    self.vastLoadManager = nil;
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (!self) { return; }
        self.callback(transaction, error);
    });
}

@end
