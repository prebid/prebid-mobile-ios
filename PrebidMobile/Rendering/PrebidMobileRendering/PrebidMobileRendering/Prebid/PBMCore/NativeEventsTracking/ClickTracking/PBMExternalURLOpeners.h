//
//  PBMExternalURLOpeners.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMExternalURLOpenerBlock.h"
#import "PBMUIApplicationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMExternalURLOpeners : NSObject

+ (PBMExternalURLOpenerBlock)applicationAsExternalUrlOpener:(id<PBMUIApplicationProtocol>)application;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
