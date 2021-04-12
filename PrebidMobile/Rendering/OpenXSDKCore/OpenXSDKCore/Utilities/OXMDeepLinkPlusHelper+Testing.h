//
//  OXMDeepLinkPlusHelper+Testing.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#ifndef OXMDeepLinkPlusHelper_Testing_h
#define OXMDeepLinkPlusHelper_Testing_h

#import "OXMDeepLinkPlusHelper.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMUIApplicationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXMDeepLinkPlusHelper (Testing)

@property (nonatomic, class, weak) id<OXMUIApplicationProtocol> application;
@property (nonatomic, class, strong) id<OXMServerConnectionProtocol> connection;

@end

NS_ASSUME_NONNULL_END

#endif /* OXMDeepLinkPlusHelper_Testing_h */
