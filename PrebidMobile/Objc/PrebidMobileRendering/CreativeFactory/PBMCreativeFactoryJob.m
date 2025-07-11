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

#import "PBMCreativeFactoryJob.h"
#import "PBMHTMLCreative.h"
#import "PBMVideoCreative.h"
#import "PBMDownloadDataHelper.h"
#import "PBMMacros.h"
#import "Log+Extensions.h"

#import "SwiftImport.h"

@interface PBMCreativeFactoryJob ()

@property (nonatomic, strong) PBMCreativeModel *creativeModel;
@property (nonatomic, copy) PBMCreativeFactoryJobFinishedCallback finishedCallback;
@property (nonatomic, strong) id<PrebidServerConnectionProtocol> serverConnection;
@property (nonatomic, strong) id<PBMTransaction>transaction;

@end

@implementation PBMCreativeFactoryJob {
    dispatch_queue_t _dispatchQueue;
}

- (nonnull instancetype)initFromCreativeModel:(nonnull PBMCreativeModel *)creativeModel
                                  transaction:(id<PBMTransaction>)transaction
                             serverConnection:(nonnull id<PrebidServerConnectionProtocol>)serverConnection
                              finishedCallback:(PBMCreativeFactoryJobFinishedCallback)finishedCallback {
    self = [super init];
    if (self) {
        self.creativeModel = creativeModel;
        self.serverConnection = serverConnection;
        self.state = PBMCreativeFactoryJobStateInitialized;
        self.finishedCallback = finishedCallback;
        self.transaction = transaction;
        NSString *uuid = [[NSUUID UUID] UUIDString];
        const char *queueName = [[NSString stringWithFormat:@"PBMCreativeFactoryJob_%@", uuid] UTF8String];
        _dispatchQueue = dispatch_queue_create(queueName, NULL);
    }
    
    return self;
}

- (void)successWithCreative:(id<PBMAbstractCreative>)creative {
    self.creative = creative;
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        if (!self) { return; }
        
        if (self.state == PBMCreativeFactoryJobStateRunning) {
            self.state = PBMCreativeFactoryJobStateSuccess;
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
        if (!self) { return; }
        
        if (self.state == PBMCreativeFactoryJobStateRunning) {
            self.state = PBMCreativeFactoryJobStateError;
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
    PBMAssert(self.creativeModel);
    if (!self.creativeModel) {
        [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Undefined creative model"
                                                  type:PBMErrorType.internalError]];
        return;
    }
    
    [self startJobTimerWithTimeInterval:timeInterval];
    
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        if (!self) { return; }
        
        if (self.state != PBMCreativeFactoryJobStateInitialized) {
            [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Tried to start PBMCreativeFactory twice"
                                                      type:PBMErrorType.internalError]];
            return;
        }
        
        self.state = PBMCreativeFactoryJobStateRunning;
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!(self.creativeModel && self.creativeModel.adConfiguration)) {
            [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Undefined creative model"
                                                      type:PBMErrorType.internalError]];
            return;
        }
        
        AdFormat *adType = self.creativeModel.adConfiguration.winningBidAdFormat;
        if (adType == AdFormat.banner || self.creativeModel.isCompanionAd) {
            [self attemptAUIDCreative];
        } else if (adType == AdFormat.video) {
            [self attemptVASTCreative];
        } else if (adType == nil) {
            PBMLogError(@"The winning bid ad format is nil.")
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
            if (!self) { return; }
            
            [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Failed to complete in specified time interval"
                                                      type:PBMErrorType.internalError]];
        });
    };
    
    timer();
}

- (void)attemptAUIDCreative {
    if (!(self.creativeModel && self.creativeModel.adConfiguration)) {
        [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Undefined creative model"
                                                  type:PBMErrorType.internalError]];
        return;
    }
    
    self.creative = [[PBMHTMLCreative alloc] initWithCreativeModel:self.creativeModel
                                                       transaction:self.transaction];
    
    if ([self.creative isKindOfClass:[PBMHTMLCreative class]]) {
        PBMHTMLCreative *creative = (PBMHTMLCreative *)self.creative;
        creative.downloadBlock = [self createLoader];
    }
    
    self.creative.creativeResolutionDelegate = self;
    [self.creative setupView];
}

- (void)attemptVASTCreative {
    if (!self.creativeModel) {
        [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Undefined creative model"
                                                  type:PBMErrorType.internalError]];
        return;
    }
    
    NSString *strUrl = self.creativeModel.videoFileURL;
    if (!strUrl) {
        [self failWithError:[PBMError errorWithDescription:@"PBMCreativeFactoryJob: Could not initialize VideoCreative without videoFileURL"]];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:strUrl];
    if (!url) {
        [self failWithError:[PBMError errorWithDescription:[NSString stringWithFormat:@"Could not create URL from url string: %@", strUrl]]];
        return;
    }
    
    PBMDownloadDataHelper *downloader = [[PBMDownloadDataHelper alloc] initWithServerConnection:self.serverConnection];
    [downloader downloadDataForURL:url maxSize:PBMVideoCreative.maxSizeForPreRenderContent completionClosure:^(NSData * _Nullable preloadedData, NSError * _Nullable error) {
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
    self.creative = [[PBMVideoCreative alloc] initWithCreativeModel:self.creativeModel transaction:self.transaction videoData:data];
    self.creative.creativeResolutionDelegate = self;
    [self.creative setupView];
}

- (NSTimeInterval)getTimeInterval {
    PBMAdConfiguration *adConfig = self.creativeModel.adConfiguration;
    if (adConfig.winningBidAdFormat == AdFormat.video || adConfig.presentAsInterstitial) {
        return Prebid.shared.creativeFactoryTimeoutPreRenderContent;
    } else {
        return Prebid.shared.creativeFactoryTimeout;
    }
}

- (PBMDownloadDataHelper *)initializeDownloadDataHelper {
    return [[PBMDownloadDataHelper alloc] initWithServerConnection:self.serverConnection];
}

- (PBMCreativeFactoryDownloadDataCompletionClosure)createLoader {
    id<PrebidServerConnectionProtocol> const connection = self.serverConnection;
    PBMCreativeFactoryDownloadDataCompletionClosure result = ^(NSURL* _Nonnull  url, PBMDownloadDataCompletionClosure _Nonnull completionBlock) {
        PBMDownloadDataHelper *downloader = [[PBMDownloadDataHelper alloc] initWithServerConnection:connection];
        [downloader downloadDataForURL:url completionClosure:^(NSData * _Nullable data, NSError * _Nullable error) {
            completionBlock ? completionBlock(data, error) : nil;
        }];
    };
    
    return result;
}

#pragma mark - PBMCreativeResolutionDelegate

- (void)creativeReady:(id<PBMAbstractCreative>)creative {
    [self successWithCreative:creative];
}

- (void)creativeFailed:(NSError *)error {
    [self failWithError:error];
}

@end
