//
//  OXAExternalURLOpeners.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAExternalURLOpenerBlock.h"
#import "OXMUIApplicationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAExternalURLOpeners : NSObject

+ (OXAExternalURLOpenerBlock)applicationAsExternalUrlOpener:(id<OXMUIApplicationProtocol>)application;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
