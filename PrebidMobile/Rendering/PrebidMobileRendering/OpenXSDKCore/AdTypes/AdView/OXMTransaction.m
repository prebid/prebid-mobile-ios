//
//  OXMTransaction.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMTransaction.h"

#import "OXMAbstractCreative.h"
#import "OXMAdConfiguration.h"
#import "OXMCreativeFactory.h"
#import "OXMCreativeModel.h"
#import "OXMError.h"
#import "OXMLog.h"
#import "OXMOpenMeasurementSession.h"
#import "OXMOpenMeasurementWrapper.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMTransactionDelegate.h"

#import "OXMMacros.h"

@interface OXMTransaction()

@property (nonatomic, strong) id<OXMServerConnectionProtocol> serverConnection;
@property (nonatomic, strong) OXMAdConfiguration *adConfiguration;
@property (nonatomic, strong) OXMCreativeFactory *creativeFactory;

@end

@implementation OXMTransaction

- (instancetype)initWithServerConnection:(id<OXMServerConnectionProtocol>)connection
                         adConfiguration:(OXMAdConfiguration*)adConfiguration
                                  models:(NSArray<OXMCreativeModel *> *)creativeModels {
    self = [super init];
    if (self) {
        self.serverConnection = connection;
        self.adConfiguration = adConfiguration;
        self.creativeModels = creativeModels;
        self.measurementWrapper = OXMOpenMeasurementWrapper.singleton;
        self.creatives = [NSMutableArray array];
    }
    
    return self;
}

- (void)startCreativeFactory {
    @weakify(self);
    OXMCreativeFactoryFinishedCallback finishedCallback = ^(NSArray<OXMAbstractCreative *> *creatives, NSError *error) {
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
    
    self.creativeFactory = [[OXMCreativeFactory alloc] initWithServerConnection:self.serverConnection transaction:self finishedCallback:finishedCallback];

    [self.creativeFactory startFactory];
}

- (nullable OXMAdDetails *)getAdDetails {
    OXMAbstractCreative *creative = [self getFirstCreative];
    
    return (creative && creative.creativeModel) ? creative.creativeModel.adDetails : nil;
}

// Return the first item in the list.  If list is empty return nil.
- (OXMAbstractCreative *)getFirstCreative {
    if ((self.creatives == nil) || (self.creatives.count == 0)) {
        return nil;
    }
    return self.creatives[0];
}

// returns the creative after the current creative.
// retuns nil if the creative is not found or is the last one on the list.
- (OXMAbstractCreative *)getCreativeAfter:(OXMAbstractCreative *)creative {
    
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
    OXMAbstractCreative *creative = [self getFirstCreative];
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^ {
        @strongify(self);
        if (creative && !self.measurementSession) {
            [creative createOpenMeasurementSession];
        }
    });
}

- (NSString *)revenueForCreativeAfter:(OXMAbstractCreative *)creative {
    OXMAbstractCreative *targetCreative = [self getCreativeAfter:creative];
    if (!targetCreative) {
        targetCreative = creative;
    }
    
    return (targetCreative && targetCreative.creativeModel) ?
        targetCreative.creativeModel.revenue :
        nil;
}

- (void)resetAdConfiguration:(OXMAdConfiguration *)adConfiguration {
    self.adConfiguration = adConfiguration;
    for (OXMCreativeModel *creativeModel in self.creativeModels) {
        creativeModel.adConfiguration = adConfiguration;
    }
}

- (void)updateAdConfiguration {
    //Update ad size in configuration from first creative model
    OXMCreativeModel *firstCreativeModel = [self.creativeModels firstObject];
    if (firstCreativeModel) {
        self.adConfiguration.size = CGSizeMake(firstCreativeModel.width, firstCreativeModel.height);
    }
}

@end
