//
//  PBMTransaction.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMTransaction.h"

#import "PBMAbstractCreative.h"
#import "PBMAdConfiguration.h"
#import "PBMCreativeFactory.h"
#import "PBMCreativeModel.h"
#import "PBMError.h"
#import "PBMLog.h"
#import "PBMOpenMeasurementSession.h"
#import "PBMOpenMeasurementWrapper.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMTransactionDelegate.h"

#import "PBMMacros.h"

@interface PBMTransaction()

@property (nonatomic, strong) id<PBMServerConnectionProtocol> serverConnection;
@property (nonatomic, strong) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong) PBMCreativeFactory *creativeFactory;

@end

@implementation PBMTransaction

- (instancetype)initWithServerConnection:(id<PBMServerConnectionProtocol>)connection
                         adConfiguration:(PBMAdConfiguration*)adConfiguration
                                  models:(NSArray<PBMCreativeModel *> *)creativeModels {
    self = [super init];
    if (self) {
        self.serverConnection = connection;
        self.adConfiguration = adConfiguration;
        self.creativeModels = creativeModels;
        self.measurementWrapper = PBMOpenMeasurementWrapper.singleton;
        self.creatives = [NSMutableArray array];
    }
    
    return self;
}

- (void)startCreativeFactory {
    @weakify(self);
    PBMCreativeFactoryFinishedCallback finishedCallback = ^(NSArray<PBMAbstractCreative *> *creatives, NSError *error) {
        @strongify(self);
        self.creativeFactory = NULL;
        if (error) {
            [self.delegate transactionFailedToLoad:self error:error];
        } else if (creatives) {
            self.creatives = [creatives mutableCopy];
            [self createOpenMeasurementSessionForFirstCreative];
            [self updateAdConfiguration];
            [self.delegate transactionReadyForDisplay:self];
        }
    };
    
    self.creativeFactory = [[PBMCreativeFactory alloc] initWithServerConnection:self.serverConnection transaction:self finishedCallback:finishedCallback];

    [self.creativeFactory startFactory];
}

- (nullable PBMAdDetails *)getAdDetails {
    PBMAbstractCreative *creative = [self getFirstCreative];
    
    return (creative && creative.creativeModel) ? creative.creativeModel.adDetails : nil;
}

// Return the first item in the list.  If list is empty return nil.
- (PBMAbstractCreative *)getFirstCreative {
    if ((self.creatives == nil) || (self.creatives.count == 0)) {
        return nil;
    }
    return self.creatives[0];
}

// returns the creative after the current creative.
// retuns nil if the creative is not found or is the last one on the list.
- (PBMAbstractCreative *)getCreativeAfter:(PBMAbstractCreative *)creative {
    
    if (!creative) {
        return [self getFirstCreative];
    }
    
    if (creative == [self.creatives lastObject]) {
        return nil;
    }
    
    NSUInteger index = [self.creatives indexOfObject:creative];

    if (index == NSNotFound) {
        return [self getFirstCreative];
    }
    
    // return the next creative
    return self.creatives[index + 1];
}

- (void)createOpenMeasurementSessionForFirstCreative {
    PBMAbstractCreative *creative = [self getFirstCreative];
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^ {
        @strongify(self);
        if (creative && !self.measurementSession) {
            [creative createOpenMeasurementSession];
        }
    });
}

- (NSString *)revenueForCreativeAfter:(PBMAbstractCreative *)creative {
    PBMAbstractCreative *targetCreative = [self getCreativeAfter:creative];
    if (!targetCreative) {
        targetCreative = creative;
    }
    
    return (targetCreative && targetCreative.creativeModel) ?
        targetCreative.creativeModel.revenue :
        nil;
}

- (void)resetAdConfiguration:(PBMAdConfiguration *)adConfiguration {
    self.adConfiguration = adConfiguration;
    for (PBMCreativeModel *creativeModel in self.creativeModels) {
        creativeModel.adConfiguration = adConfiguration;
    }
}

- (void)updateAdConfiguration {
    //Update ad size in configuration from first creative model
    PBMCreativeModel *firstCreativeModel = [self.creativeModels firstObject];
    if (firstCreativeModel) {
        self.adConfiguration.size = CGSizeMake(firstCreativeModel.width, firstCreativeModel.height);
    }
}

@end
