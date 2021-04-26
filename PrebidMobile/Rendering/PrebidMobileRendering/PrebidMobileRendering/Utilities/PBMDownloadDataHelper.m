//
//  PBMDownloadSizeHelper.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMConstants.h"
#import "PBMVideoCreative.h"
#import "PBMDownloadDataHelper.h"
#import "PBMError.h"
#import "PBMServerResponse.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMMacros.h"

#pragma mark - Private Properties

@interface PBMDownloadDataHelper()

@property (nonatomic, weak) id<PBMServerConnectionProtocol> pbmServerConnection;

@end

#pragma mark - Implementation

@implementation PBMDownloadDataHelper

#pragma mark - Initialization

- (nonnull instancetype)initWithPBMServerConnection:(nonnull id<PBMServerConnectionProtocol>)pbmServerConnection {
    self = [super init];
    if (self) {
        PBMAssert(pbmServerConnection);
        
        self.pbmServerConnection = pbmServerConnection;
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)downloadDataForURL:(nullable NSURL *)url
                   maxSize:(NSInteger)maxSize
         completionClosure:(nonnull PBMDownloadDataCompletionClosure)completionClosure{
    
    if (!completionClosure) {
        return;
    }

    [self.pbmServerConnection head:url.absoluteString timeout:PBMTimeInterval.FIRE_AND_FORGET_TIMEOUT callback:^(PBMServerResponse * _Nonnull serverResponse) {
  
        NSString *strContentLength = serverResponse ? serverResponse.responseHeaders[@"Content-Length"] : nil;
        
        // NOTE: need to be sure that value is an integer. [NSString toInt:] can't be used. Because it returns 0 for strings.
        int contentLength = 0;
        BOOL isIntegerValue = [[NSScanner scannerWithString:strContentLength] scanInt:&contentLength];
        
        NSNumber* sizeInBytes = (isIntegerValue && contentLength >= 0) ? @(contentLength) : nil;
        
        if (!sizeInBytes) {
            NSString *description = [NSString stringWithFormat:@"Unable to determine video file size: %@", url];
            completionClosure(nil, [PBMError errorWithDescription:description]);
            return;
        }
        
        if (sizeInBytes.integerValue > maxSize) {
            NSString *description = [NSString stringWithFormat:@"Cannot preRender video at %@. Size of %ld bytes is greater than the maximum size for preloading of %ld bytes.", url, (long)sizeInBytes.integerValue, (long)maxSize];
            completionClosure(nil, [PBMError errorWithDescription:description]);
            return;
        }
        
        [self downloadDataForURL:url completionClosure:completionClosure];
    }];
}

- (void)downloadDataForURL:(nullable NSURL *)url completionClosure:(nonnull PBMDownloadDataCompletionClosure)completionClosure {
    if (!completionClosure) {
        return;
    }
    
    [self.pbmServerConnection download:url.absoluteString callback:^(PBMServerResponse * _Nonnull response) {
        if (!response) {
            completionClosure(nil, [PBMError errorWithDescription:[NSString stringWithFormat:@"The response is empty for loading data from %@ ", url]]);
            return;
        }
        
        completionClosure(response.rawData, response.error);
    }];
}

@end
