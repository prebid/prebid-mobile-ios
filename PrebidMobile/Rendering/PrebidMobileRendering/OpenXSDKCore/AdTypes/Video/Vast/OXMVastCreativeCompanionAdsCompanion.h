//
//  OXMVastCreativeCompanionAdsCompanion.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMVastTrackingEvents.h"
#import "OXMVastResourceContainerProtocol.h"

@interface OXMVastCreativeCompanionAdsCompanion : NSObject <OXMVastResourceContainerProtocol>

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong, nonnull) OXMVastTrackingEvents *trackingEvents;

@property (nonatomic, assign) NSInteger assetWidth;
@property (nonatomic, assign) NSInteger assetHeight;
@property (nonatomic, copy, nullable) NSString *companionIdentifier;
@property (nonatomic, copy, nullable) NSString *clickThroughURI;
@property (nonatomic, copy, nullable) NSString *adParameters;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *clickTrackingURIs;

// OXMVastResourceContainer
@property (nonatomic, assign) OXMVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

@end
