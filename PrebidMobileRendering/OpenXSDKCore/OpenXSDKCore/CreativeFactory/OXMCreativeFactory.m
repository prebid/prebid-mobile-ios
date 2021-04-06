//
//  OXMCreativeFactory.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMCreativeFactory.h"
#import "OXMCreativeFactoryJob.h"
#import "OXMMacros.h"
#import "OXMError.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMTransaction.h"
#import "OXMAbstractCreative.h"

@interface OXMCreativeFactory ()

@property (strong, nonatomic) id<OXMServerConnectionProtocol> serverConnection;
@property (strong, nonatomic) OXMTransaction *transaction;
@property (strong, nonatomic) NSArray<OXMCreativeFactoryJob *> *jobs;
@property (copy, nonatomic) OXMCreativeFactoryFinishedCallback finishedCallback;

@end

@implementation OXMCreativeFactory {
    dispatch_queue_t _dispatchQueue;
}

- (nonnull instancetype)initWithServerConnection:(id<OXMServerConnectionProtocol>)serverConnection
                                     transaction:(OXMTransaction *)transaction
                                     finishedCallback:( OXMCreativeFactoryFinishedCallback)finishedCallback {
    self = [super init];
    if (self) {
        OXMAssert(serverConnection && transaction);
        self.serverConnection = serverConnection;
        self.transaction = transaction;
        self.finishedCallback = finishedCallback;
        NSString *uuid = [[NSUUID UUID] UUIDString];
        const char *queueName = [[NSString stringWithFormat:@"OXMCreativeFactory_%@", uuid] UTF8String];
        _dispatchQueue = dispatch_queue_create(queueName, NULL);    }
    
    return self;
}

- (void)startFactory {
    self.jobs = [self convertCreativeModels];
    
    if (self.jobs.count < 1) {
        NSError *error = [OXMError errorWithMessage:@"OXMCreativeFactory: There were no jobs for processing" type:OXAErrorTypeInternalError];
        self.finishedCallback(NULL, error);
        return;
    }
    
    for (OXMCreativeFactoryJob *job in self.jobs) {
        [job startJob];
    }
}

- (NSArray<OXMCreativeFactoryJob *> *)convertCreativeModels {
    NSMutableArray<OXMCreativeFactoryJob *> *jobsArray = [NSMutableArray new];
    for (OXMCreativeModel *model in self.transaction.creativeModels) {
        @weakify(self);
        OXMCreativeFactoryJob *newJob =
        [[OXMCreativeFactoryJob alloc] initFromCreativeModel:model transaction:self.transaction
                                            serverConnection:self.serverConnection
                                            finishedCallback: ^(OXMCreativeFactoryJob *job, NSError *error) {
                                                @strongify(self);
                                                [self onFinishedJob:job error:error];
                                            }];
        [jobsArray addObject:newJob];
    }
    
    return [[NSArray alloc] initWithArray:jobsArray];
}

- (void)onFinishedJob:(OXMCreativeFactoryJob *)job error:(NSError *)error {
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        if (error) {
            OXMLogInfo(@"OXMCreativeFactory: %@", error.description);
            self.finishedCallback(NULL, error);
            return;
        }
        
        if ([self allJobsSucceeded]) {
            NSMutableArray<OXMAbstractCreative *> *finishedCreatives = [NSMutableArray new];
            for (OXMCreativeFactoryJob *job in self.jobs) {
                [finishedCreatives addObject:job.creative];
            }
            self.finishedCallback(finishedCreatives, NULL);
        }
    });
}

- (BOOL)allJobsSucceeded {
    for (OXMCreativeFactoryJob *job in self.jobs) {
        if (job.state != OXMCreativeFactoryJobStateSuccess) {
            return false;
        }
    }
    return true;
}

@end
