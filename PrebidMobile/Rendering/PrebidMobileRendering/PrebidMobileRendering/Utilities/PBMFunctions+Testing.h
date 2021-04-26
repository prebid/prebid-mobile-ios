//
//  PBMFunctions+Testing.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMFunctions.h"
#import "PBMUIApplicationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMFunctions (Testing)
@property (nonatomic, class, weak) id<PBMUIApplicationProtocol> application;
@end

NS_ASSUME_NONNULL_END
