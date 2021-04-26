//
//  PBMVastCreativeCompanionAdsCompanion.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMVastTrackingEvents.h"
#import "PBMVastResourceContainerProtocol.h"

@interface PBMVastCreativeCompanionAdsCompanion : NSObject <PBMVastResourceContainerProtocol>

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong, nonnull) PBMVastTrackingEvents *trackingEvents;

@property (nonatomic, assign) NSInteger assetWidth;
@property (nonatomic, assign) NSInteger assetHeight;
@property (nonatomic, copy, nullable) NSString *companionIdentifier;
@property (nonatomic, copy, nullable) NSString *clickThroughURI;
@property (nonatomic, copy, nullable) NSString *adParameters;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *clickTrackingURIs;

// PBMVastResourceContainer
@property (nonatomic, assign) PBMVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

@end
