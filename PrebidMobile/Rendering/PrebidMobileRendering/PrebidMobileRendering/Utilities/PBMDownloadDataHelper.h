//
//  PBMDownloadDataHelper.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PBMServerConnectionProtocol;

typedef void (^PBMDownloadDataCompletionClosure)(NSData* _Nullable, NSError* _Nullable);

@interface PBMDownloadDataHelper : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithPBMServerConnection:(nonnull id<PBMServerConnectionProtocol>)pbmServerConnection NS_DESIGNATED_INITIALIZER;

- (void)downloadDataForURL:(nullable NSURL *)url
         completionClosure:(nonnull PBMDownloadDataCompletionClosure)completionClosure;

- (void)downloadDataForURL:(nullable NSURL *)url
                   maxSize:(NSInteger)maxSize
         completionClosure:(nonnull PBMDownloadDataCompletionClosure)completionClosure;

@end
