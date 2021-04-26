//
//  PBMCreativeFactory.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "PBMCreativeFactory.h"
#import "PBMCreativeFactoryJob.h"
#import "PBMMacros.h"
#import "PBMError.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMTransaction.h"
#import "PBMAbstractCreative.h"

@interface PBMCreativeFactory ()

@property (strong, nonatomic) id<PBMServerConnectionProtocol> serverConnection;
@property (strong, nonatomic) PBMTransaction *transaction;
@property (strong, nonatomic) NSArray<PBMCreativeFactoryJob *> *jobs;
@property (copy, nonatomic) PBMCreativeFactoryFinishedCallback finishedCallback;

@end

@implementation PBMCreativeFactory {
    dispatch_queue_t _dispatchQueue;
}

- (nonnull instancetype)initWithServerConnection:(id<PBMServerConnectionProtocol>)serverConnection
                                     transaction:(PBMTransaction *)transaction
                                     finishedCallback:( PBMCreativeFactoryFinishedCallback)finishedCallback {
    self = [super init];
    if (self) {
        PBMAssert(serverConnection && transaction);
        self.serverConnection = serverConnection;
        self.transaction = transaction;
        self.finishedCallback = finishedCallback;
        NSString *uuid = [[NSUUID UUID] UUIDString];
        const char *queueName = [[NSString stringWithFormat:@"PBMCreativeFactory_%@", uuid] UTF8String];
        _dispatchQueue = dispatch_queue_create(queueName, NULL);    }
    
    return self;
}

- (void)startFactory {
    self.jobs = [self convertCreativeModels];
    
    if (self.jobs.count < 1) {
        NSError *error = [PBMError errorWithMessage:@"PBMCreativeFactory: There were no jobs for processing" type:PBMErrorTypeInternalError];
        self.finishedCallback(NULL, error);
        return;
    }
    
    for (PBMCreativeFactoryJob *job in self.jobs) {
        [job startJob];
    }
}

- (NSArray<PBMCreativeFactoryJob *> *)convertCreativeModels {
    NSMutableArray<PBMCreativeFactoryJob *> *jobsArray = [NSMutableArray new];
    for (PBMCreativeModel *model in self.transaction.creativeModels) {
        @weakify(self);
        PBMCreativeFactoryJob *newJob =
        [[PBMCreativeFactoryJob alloc] initFromCreativeModel:model transaction:self.transaction
                                            serverConnection:self.serverConnection
                                            finishedCallback: ^(PBMCreativeFactoryJob *job, NSError *error) {
                                                @strongify(self);
                                                [self onFinishedJob:job error:error];
                                            }];
        [jobsArray addObject:newJob];
    }
    
    return [[NSArray alloc] initWithArray:jobsArray];
}

- (void)onFinishedJob:(PBMCreativeFactoryJob *)job error:(NSError *)error {
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        if (error) {
            PBMLogInfo(@"PBMCreativeFactory: %@", error.description);
            self.finishedCallback(NULL, error);
            return;
        }
        
        if ([self allJobsSucceeded]) {
            NSMutableArray<PBMAbstractCreative *> *finishedCreatives = [NSMutableArray new];
            for (PBMCreativeFactoryJob *job in self.jobs) {
                [finishedCreatives addObject:job.creative];
            }
            self.finishedCallback(finishedCreatives, NULL);
        }
    });
}

- (BOOL)allJobsSucceeded {
    for (PBMCreativeFactoryJob *job in self.jobs) {
        if (job.state != PBMCreativeFactoryJobStateSuccess) {
            return false;
        }
    }
    return true;
}

@end
