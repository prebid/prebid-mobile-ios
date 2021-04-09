//
//  OXMAdLoadManager.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdDetails.h"
#import "OXMAdLoadManagerBase.h"
#import "OXMAdRequesterVAST.h"
#import "OXMCreativeModelCollectionMakerVAST.h"
#import "OXMMacros.h"
#import "OXMServerResponse.h"
#import "OXMTransaction.h"

#pragma mark - Private Extention

@interface OXMAdLoadManagerBase ()

@property (nonatomic, strong) OXMTransaction *currentTransaction;

@end

#pragma mark - Implementation

@implementation OXMAdLoadManagerBase

- (instancetype)initWithConnection:(id<OXMServerConnectionProtocol>)connection
                   adConfiguration:(OXMAdConfiguration *)adConfiguration {
    self = [super init];
    if (self) {
        OXMAssert(connection);
        
        self.connection = connection;
        self.adConfiguration = adConfiguration;
        self.dispatchQueue = dispatch_queue_create("OXMAdLoadManager", NULL);
    }
    return self;
}

- (void)makeCreativesWithCreativeModels:(NSArray<OXMCreativeModel *> *)creativeModels {
    // Create the transaction(s)
    // Currently, we only handle one transaction.
    self.currentTransaction = [[OXMTransaction alloc] initWithServerConnection:self.connection
                                                               adConfiguration:self.adConfiguration
                                                                        models:creativeModels];
    self.currentTransaction.delegate = self;
    
    [self.currentTransaction startCreativeFactory];
}

- (void)requestCompletedFailure:(NSError *)error {
    OXMLogWhereAmI();
    
    [self.adLoadManagerDelegate loadManager:self failedToLoadTransaction:nil error:error];
}

#pragma mark - OXMTransactionDelegate

- (void)transactionReadyForDisplay:(OXMTransaction *) transaction {
    [self.adLoadManagerDelegate loadManager:self didLoadTransaction:transaction];
        
    // When transaction is ready we should pass it to the receiver and release the property in this class.
    // Transaction is not needed in the load manager anymore.
    self.currentTransaction = nil;
}

- (void)transactionFailedToLoad:(OXMTransaction *) transaction error:(NSError *) error {
    [self.adLoadManagerDelegate loadManager:self failedToLoadTransaction :transaction error:error];
}

@end
