//
//  PBMVastResourceContainerProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMVastGlobals.h"

NS_SWIFT_NAME(PBMVastResourceContainer)
@protocol PBMVastResourceContainerProtocol

@property (nonatomic, assign) PBMVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

@end
