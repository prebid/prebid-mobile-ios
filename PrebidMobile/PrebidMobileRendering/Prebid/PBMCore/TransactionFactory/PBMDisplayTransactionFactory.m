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

#import "PBMDisplayTransactionFactory.h"

#import "PBMNativeFunctions.h"
#import "PBMCreativeModel.h"
#import "PBMLog.h"
#import "PBMTransaction.h"
#import "PBMTransactionDelegate.h"

#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

@interface PBMDisplayTransactionFactory() <PBMTransactionDelegate>

@property (nonatomic, strong, readonly, nonnull) Bid *bid;
@property (nonatomic, strong, readonly, nonnull) AdUnitConfig *adConfiguration;
@property (nonatomic, strong, readonly, nonnull) id<PBMServerConnectionProtocol> connection;

// NOTE: need to call the completion callback only in the main thread
// use onFinishedWithTransaction
@property (nonatomic, copy, readonly, nonnull) PBMTransactionFactoryCallback callback;

@property (nonatomic, strong, nullable) PBMTransaction *transaction;
@property (nonatomic, readonly) BOOL isLoading;

@end



@implementation PBMDisplayTransactionFactory

// MARK: - Public API

- (instancetype)initWithBid:(Bid *)bid
            adConfiguration:(AdUnitConfig *)adConfiguration
                 connection:(id<PBMServerConnectionProtocol>)connection
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
    
    [self loadHTMLTransaction:adMarkup];
    
    return YES;
}

// MARK: - PBMTransactionDelegate protocol

- (void)transactionReadyForDisplay:(PBMTransaction *)transaction {
    self.transaction = nil;
    [self onFinishedWithTransaction:transaction error:nil];
}

- (void)transactionFailedToLoad:(PBMTransaction *)transaction error:(NSError *)error {
    self.transaction = nil;
    [self onFinishedWithTransaction:nil error:error];
}

// MARK: - Private Helpers

- (BOOL)isLoading {
    return (self.transaction != nil);
}

- (void)loadHTMLTransaction:(NSString *)adMarkup {
    NSMutableArray<PBMCreativeModel *> * const creativeModels = [[NSMutableArray alloc] init];

    [creativeModels addObject:[self htmlCreativeModelFromBid:self.bid
                                                    adMarkup:adMarkup
                                             adConfiguration:self.adConfiguration]];
    
    self.transaction = [[PBMTransaction alloc] initWithServerConnection:self.connection
                                                        adConfiguration:self.adConfiguration.adConfiguration
                                                                 models:creativeModels];
    self.transaction.delegate = self;
    if (self.bid.skadn) {
        self.transaction.skadInfo = self.bid.skadn;
    }
    [self.transaction startCreativeFactory];
}

- (PBMCreativeModel *)htmlCreativeModelFromBid:(Bid *)bid
                                      adMarkup:(NSString *)adMarkup
                               adConfiguration:(AdUnitConfig *)adConfiguration {
    PBMCreativeModel * const model = [[PBMCreativeModel alloc] init];
    NSString *html = nil;
    if (adConfiguration.adFormat != PBMAdFormatNativeInternal) {
        model.html = adMarkup;
    } else {
        if (adConfiguration.nativeAdConfiguration.nativeStylesCreative.length == 0) {
            PBMLogError(@"Native Styles creative string is empty.");
            model.html = @"";
        } else {
            html = [PBMNativeFunctions populateNativeAdTemplate:adConfiguration.nativeAdConfiguration.nativeStylesCreative
                                                  withTargeting:bid.targetingInfo
                                                          error:nil];
            model.html = html ?: @"";
        }
    }
    
    model.width = bid.size.width;
    model.height = bid.size.height;
    model.adConfiguration = adConfiguration.adConfiguration;
    return model;
}

- (void)onFinishedWithTransaction:(PBMTransaction *)transaction error:(NSError *)error {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.callback(transaction, error);
    });
}

@end
