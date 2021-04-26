//
//  PBMCreativeFactory.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMDownloadDataHelper.h"

@protocol PBMServerConnectionProtocol;
@class PBMTransaction;
@class PBMAbstractCreative;

typedef void(^PBMCreativeFactoryFinishedCallback)(NSArray<PBMAbstractCreative *> * _Nullable, NSError * _Nullable);
typedef void(^PBMCreativeFactoryDownloadDataCompletionClosure)(NSURL* _Nonnull, PBMDownloadDataCompletionClosure _Nonnull);

@interface PBMCreativeFactory : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithServerConnection:(nonnull id<PBMServerConnectionProtocol>)serverConnection
                                     transaction:(nonnull PBMTransaction *)transaction
                                finishedCallback:(nonnull PBMCreativeFactoryFinishedCallback)finishedCallback
NS_DESIGNATED_INITIALIZER;

- (void)startFactory;

@end


