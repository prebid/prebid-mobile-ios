//
//  OXMVastResourceContainerProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMVastGlobals.h"

NS_SWIFT_NAME(OXMVastResourceContainer)
@protocol OXMVastResourceContainerProtocol

@property (nonatomic, assign) OXMVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

@end
