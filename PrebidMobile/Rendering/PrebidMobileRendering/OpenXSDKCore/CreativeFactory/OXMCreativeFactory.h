//
//  OXMCreativeFactory.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMDownloadDataHelper.h"

@protocol OXMServerConnectionProtocol;
@class OXMTransaction;
@class OXMAbstractCreative;

typedef void(^OXMCreativeFactoryFinishedCallback)(NSArray<OXMAbstractCreative *> * _Nullable, NSError * _Nullable);
typedef void(^OXMCreativeFactoryDownloadDataCompletionClosure)(NSURL* _Nonnull, OXMDownloadDataCompletionClosure _Nonnull);

@interface OXMCreativeFactory : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithServerConnection:(nonnull id<OXMServerConnectionProtocol>)serverConnection
                                     transaction:(nonnull OXMTransaction *)transaction
                                finishedCallback:(nonnull OXMCreativeFactoryFinishedCallback)finishedCallback
NS_DESIGNATED_INITIALIZER;

- (void)startFactory;

@end


