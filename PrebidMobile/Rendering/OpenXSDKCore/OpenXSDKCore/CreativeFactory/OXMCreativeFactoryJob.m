//
//  OXMCreativeFactoryJob.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMCreativeFactoryJob.h"
#import "OXMCreativeModel.h"
#import "OXMHTMLCreative.h"
#import "OXMVideoCreative.h"
#import "OXMAbstractCreative.h"
#import "OXMAdConfiguration.h"
#import "OXASDKConfiguration.h"
#import "OXMDownloadDataHelper.h"
#import "OXMTransaction.h"
#import "OXMMacros.h"
#import "OXMError.h"

@interface OXMCreativeFactoryJob ()

@property (nonatomic, strong) OXMCreativeModel *creativeModel;
@property (nonatomic, copy) OXMCreativeFactoryJobFinishedCallback finishedCallback;
@property (nonatomic, strong) id<OXMServerConnectionProtocol> serverConnection;
@property (nonatomic, strong) OXMTransaction *transaction;

@end

@implementation OXMCreativeFactoryJob {
    dispatch_queue_t _dispatchQueue;
}

- (nonnull instancetype)initFromCreativeModel:(nonnull OXMCreativeModel *)creativeModel
                                  transaction:(OXMTransaction *)transaction
                             serverConnection:(nonnull id<OXMServerConnectionProtocol>)serverConnection
                              finishedCallback:(OXMCreativeFactoryJobFinishedCallback)finishedCallback {
    self = [super init];
    if (self) {
        self.creativeModel = creativeModel;
        self.serverConnection = serverConnection;
        self.state = OXMCreativeFactoryJobStateInitialized;
        self.finishedCallback = finishedCallback;
        self.transaction = transaction;
        NSString *uuid = [[NSUUID UUID] UUIDString];
        const char *queueName = [[NSString stringWithFormat:@"OXMCreativeFactoryJob_%@", uuid] UTF8String];
        _dispatchQueue = dispatch_queue_create(queueName, NULL);
    }
    
    return self;
}

- (void)successWithCreative:(OXMAbstractCreative *)creative {
    self.creative = creative;
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        if (self.state == OXMCreativeFactoryJobStateRunning) {
            self.state = OXMCreativeFactoryJobStateSuccess;
            if (self.finishedCallback) {
                self.finishedCallback(self, NULL);
            }
        }
    });
}

- (void)failWithError:(NSError *)error {
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        if (self.state == OXMCreativeFactoryJobStateRunning) {
            self.state = OXMCreativeFactoryJobStateError;
            if (self.finishedCallback) {
                self.finishedCallback(self, error);
            }
        }
    });
}

- (void)startJob {
    [self startJobWithTimeInterval:[self getTimeInterval]];
}

/*
 For internal use only
 */
- (void)startJobWithTimeInterval:(NSTimeInterval)timeInterval {
    OXMAssert(self.creativeModel);
    if (!self.creativeModel) {
        [self failWithError:[OXMError errorWithMessage:@"OXMCreativeFactoryJob: Undefined creative model" type:OXAErrorTypeInternalError]];
        return;
    }
    
    [self startJobTimerWithTimeInterval:timeInterval];
    
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        if (self.state != OXMCreativeFactoryJobStateInitialized) {
            [self failWithError:[OXMError errorWithMessage:@"OXMCreativeFactoryJob: Tried to start OXMCreativeFactory twice" type:OXAErrorTypeInternalError]];
            return;
        }
        
        self.state = OXMCreativeFactoryJobStateRunning;
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!(self.creativeModel && self.creativeModel.adConfiguration)) {
            [self failWithError:[OXMError errorWithMessage:@"OXMCreativeFactoryJob: Undefined creative model" type:OXAErrorTypeInternalError]];
            return;
        }
        
        OXMAdFormat adType = self.creativeModel.adConfiguration.adFormat;
        if (adType == OXMAdFormatVideo) {
            [self attemptVASTCreative];
        } else if (adType == OXMAdFormatDisplay || adType == OXMAdFormatNative) {
            [self attemptAUIDCreative];
        }
    });
}

- (void)startJobTimerWithTimeInterval:(NSTimeInterval)timeInterval {
    @weakify(self);
    __block void (^timer)(void) = ^{
        double delayInSeconds = timeInterval;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^(void){
            @strongify(self);
            [self failWithError:[OXMError errorWithMessage:@"OXMCreativeFactoryJob: Failed to complete in specified time interval" type:OXAErrorTypeInternalError]];
        });
    };
    
    timer();
}

- (void)attemptAUIDCreative {
    if (!(self.creativeModel && self.creativeModel.adConfiguration)) {
        [self failWithError:[OXMError errorWithMessage:@"OXMCreativeFactoryJob: Undefined creative model" type:OXAErrorTypeInternalError]];
        return;
    }
    
    self.creative = [[OXMHTMLCreative alloc] initWithCreativeModel:self.creativeModel
                                                       transaction:self.transaction];
    
    if ([self.creative isKindOfClass:[OXMHTMLCreative class]]) {
        OXMHTMLCreative *creative = (OXMHTMLCreative *)self.creative;
        creative.downloadBlock = [self createLoader];
    }
    
    self.creative.creativeResolutionDelegate = self;
    [self.creative setupView];
}

- (void)attemptVASTCreative {
    if (!self.creativeModel) {
        [self failWithError:[OXMError errorWithMessage:@"OXMCreativeFactoryJob: Undefined creative model" type:OXAErrorTypeInternalError]];
        return;
    }
    
    NSString *strUrl = self.creativeModel.videoFileURL;
    if (!strUrl) {
        [self failWithError:[OXMError errorWithDescription:@"OXMCreativeFactoryJob: Could not initialize VideoCreative without videoFileURL"]];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:strUrl];
    if (!url) {
        [self failWithError:[OXMError errorWithDescription:[NSString stringWithFormat:@"Could not create URL from url string: %@", strUrl]]];
        return;
    }
    
    OXMDownloadDataHelper *downloader = [[OXMDownloadDataHelper alloc] initWithOXMServerConnection:self.serverConnection];
    [downloader downloadDataForURL:url maxSize:OXMVideoCreative.maxSizeForPreRenderContent completionClosure:^(NSData * _Nullable preloadedData, NSError * _Nullable error) {
        if (error) {
            [self failWithError:error];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initializeVideoCreative:preloadedData];
        });
    }];
}

- (void)initializeVideoCreative:(NSData *)data {
    self.creative = [[OXMVideoCreative alloc] initWithCreativeModel:self.creativeModel transaction:self.transaction videoData:data];
    self.creative.creativeResolutionDelegate = self;
    [self.creative setupView];
}

- (NSTimeInterval)getTimeInterval {
    OXMAdConfiguration *adConfig = self.creativeModel.adConfiguration;
    if (adConfig.adFormat == OXMAdFormatVideo || adConfig.presentAsInterstitial) {
        return OXASDKConfiguration.singleton.creativeFactoryTimeoutPreRenderContent;
    } else {
        return OXASDKConfiguration.singleton.creativeFactoryTimeout;
    }
}

- (OXMDownloadDataHelper *)initializeDownloadDataHelper {
    return [[OXMDownloadDataHelper alloc] initWithOXMServerConnection:self.serverConnection];
}

- (OXMCreativeFactoryDownloadDataCompletionClosure)createLoader {
    id<OXMServerConnectionProtocol> const connection = self.serverConnection;
    OXMCreativeFactoryDownloadDataCompletionClosure result = ^(NSURL* _Nonnull  url, OXMDownloadDataCompletionClosure _Nonnull completionBlock) {
        OXMDownloadDataHelper *downloader = [[OXMDownloadDataHelper alloc] initWithOXMServerConnection:connection];
        [downloader downloadDataForURL:url completionClosure:^(NSData * _Nullable data, NSError * _Nullable error) {
            completionBlock ? completionBlock(data, error) : nil;
        }];
    };
    
    return result;
}

#pragma mark - OXMCreativeResolutionDelegate

- (void)creativeReady:(OXMAbstractCreative *)creative {
    [self successWithCreative:creative];
}

- (void)creativeFailed:(NSError *)error {
    [self failWithError:error];
}

@end
