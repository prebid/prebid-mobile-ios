//
//  OXMDownloadDataHelper.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OXMServerConnectionProtocol;

typedef void (^OXMDownloadDataCompletionClosure)(NSData* _Nullable, NSError* _Nullable);

@interface OXMDownloadDataHelper : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithOXMServerConnection:(nonnull id<OXMServerConnectionProtocol>)oxmServerConnection NS_DESIGNATED_INITIALIZER;

- (void)downloadDataForURL:(nullable NSURL *)url
         completionClosure:(nonnull OXMDownloadDataCompletionClosure)completionClosure;

- (void)downloadDataForURL:(nullable NSURL *)url
                   maxSize:(NSInteger)maxSize
         completionClosure:(nonnull OXMDownloadDataCompletionClosure)completionClosure;

@end
