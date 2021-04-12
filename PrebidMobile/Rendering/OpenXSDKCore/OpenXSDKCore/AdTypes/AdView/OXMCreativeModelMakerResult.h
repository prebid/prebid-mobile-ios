//
//  OXMCreativeModelMakerResult.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OXMCreativeModel;

typedef void(^OXMCreativeModelMakerSuccessCallback)(NSArray<OXMCreativeModel *> * _Nonnull);
typedef void(^OXMCreativeModelMakerFailureCallback)(NSError * _Nonnull);
