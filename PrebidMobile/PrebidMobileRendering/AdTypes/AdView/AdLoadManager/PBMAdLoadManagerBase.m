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

#import "PBMAdDetails.h"
#import "PBMAdLoadManagerBase.h"
#import "PBMAdRequesterVAST.h"
#import "PBMCreativeModelCollectionMakerVAST.h"
#import "PBMMacros.h"
#import "PBMServerResponse.h"
#import "PBMTransaction.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

#pragma mark - Private Extention

@interface PBMAdLoadManagerBase ()

@property (nonatomic, strong) PBMTransaction *currentTransaction;

@end

#pragma mark - Implementation

@implementation PBMAdLoadManagerBase

- (instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)connection
                   adConfiguration:(AdConfiguration *)adConfiguration {
    self = [super init];
    if (self) {
        PBMAssert(connection);
        
        self.connection = connection;
        self.adConfiguration = adConfiguration;
        self.dispatchQueue = dispatch_queue_create("PBMAdLoadManager", NULL);
    }
    return self;
}

- (void)makeCreativesWithCreativeModels:(NSArray<PBMCreativeModel *> *)creativeModels {
    // Create the transaction(s)
    // Currently, we only handle one transaction.
    self.currentTransaction = [[PBMTransaction alloc] initWithServerConnection:self.connection
                                                               adConfiguration:self.adConfiguration
                                                                        models:creativeModels];
    self.currentTransaction.delegate = self;
    
    [self.currentTransaction startCreativeFactory];
}

- (void)requestCompletedFailure:(NSError *)error {
    PBMLogWhereAmI();
    
    [self.adLoadManagerDelegate loadManager:self failedToLoadTransaction:nil error:error];
}

#pragma mark - PBMTransactionDelegate

- (void)transactionReadyForDisplay:(PBMTransaction *) transaction {
    [self.adLoadManagerDelegate loadManager:self didLoadTransaction:transaction];
        
    // When transaction is ready we should pass it to the receiver and release the property in this class.
    // Transaction is not needed in the load manager anymore.
    self.currentTransaction = nil;
}

- (void)transactionFailedToLoad:(PBMTransaction *) transaction error:(NSError *) error {
    [self.adLoadManagerDelegate loadManager:self failedToLoadTransaction :transaction error:error];
}

@end
