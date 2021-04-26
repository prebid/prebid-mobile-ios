//
//  PBMDeepLinkPlusHelper+Testing.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#ifndef PBMDeepLinkPlusHelper_Testing_h
#define PBMDeepLinkPlusHelper_Testing_h

#import "PBMDeepLinkPlusHelper.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMUIApplicationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMDeepLinkPlusHelper (Testing)

@property (nonatomic, class, weak) id<PBMUIApplicationProtocol> application;
@property (nonatomic, class, strong) id<PBMServerConnectionProtocol> connection;

@end

NS_ASSUME_NONNULL_END

#endif /* PBMDeepLinkPlusHelper_Testing_h */
