//
//  PBMCreativeModelMakerResult.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PBMCreativeModel;

typedef void(^PBMCreativeModelMakerSuccessCallback)(NSArray<PBMCreativeModel *> * _Nonnull);
typedef void(^PBMCreativeModelMakerFailureCallback)(NSError * _Nonnull);
