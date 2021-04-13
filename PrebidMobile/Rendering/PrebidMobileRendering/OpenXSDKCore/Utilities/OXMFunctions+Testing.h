//
//  OXMFunctions+Testing.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMFunctions.h"
#import "OXMUIApplicationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXMFunctions (Testing)
@property (nonatomic, class, weak) id<OXMUIApplicationProtocol> application;
@end

NS_ASSUME_NONNULL_END
