//
//  OXMDownloadSizeHelper.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMConstants.h"
#import "OXMVideoCreative.h"
#import "OXMDownloadDataHelper.h"
#import "OXMError.h"
#import "OXMServerResponse.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMMacros.h"

#pragma mark - Private Properties

@interface OXMDownloadDataHelper()

@property (nonatomic, weak) id<OXMServerConnectionProtocol> oxmServerConnection;

@end

#pragma mark - Implementation

@implementation OXMDownloadDataHelper

#pragma mark - Initialization

- (nonnull instancetype)initWithOXMServerConnection:(nonnull id<OXMServerConnectionProtocol>)oxmServerConnection {
    self = [super init];
    if (self) {
        OXMAssert(oxmServerConnection);
        
        self.oxmServerConnection = oxmServerConnection;
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)downloadDataForURL:(nullable NSURL *)url
                   maxSize:(NSInteger)maxSize
         completionClosure:(nonnull OXMDownloadDataCompletionClosure)completionClosure{
    
    if (!completionClosure) {
        return;
    }

    [self.oxmServerConnection head:url.absoluteString timeout:OXMTimeInterval.FIRE_AND_FORGET_TIMEOUT callback:^(OXMServerResponse * _Nonnull serverResponse) {
  
        NSString *strContentLength = serverResponse ? serverResponse.responseHeaders[@"Content-Length"] : nil;
        
        // NOTE: need to be sure that value is an integer. [NSString toInt:] can't be used. Because it returns 0 for strings.
        int contentLength = 0;
        BOOL isIntegerValue = [[NSScanner scannerWithString:strContentLength] scanInt:&contentLength];
        
        NSNumber* sizeInBytes = (isIntegerValue && contentLength >= 0) ? @(contentLength) : nil;
        
        if (!sizeInBytes) {
            NSString *description = [NSString stringWithFormat:@"Unable to determine video file size: %@", url];
            completionClosure(nil, [OXMError errorWithDescription:description]);
            return;
        }
        
        if (sizeInBytes.integerValue > maxSize) {
            NSString *description = [NSString stringWithFormat:@"Cannot preRender video at %@. Size of %ld bytes is greater than the maximum size for preloading of %ld bytes.", url, (long)sizeInBytes.integerValue, (long)maxSize];
            completionClosure(nil, [OXMError errorWithDescription:description]);
            return;
        }
        
        [self downloadDataForURL:url completionClosure:completionClosure];
    }];
}

- (void)downloadDataForURL:(nullable NSURL *)url completionClosure:(nonnull OXMDownloadDataCompletionClosure)completionClosure {
    if (!completionClosure) {
        return;
    }
    
    [self.oxmServerConnection download:url.absoluteString callback:^(OXMServerResponse * _Nonnull response) {
        if (!response) {
            completionClosure(nil, [OXMError errorWithDescription:[NSString stringWithFormat:@"The response is empty for loading data from %@ ", url]]);
            return;
        }
        
        completionClosure(response.rawData, response.error);
    }];
}

@end
