//
//  PBMVastCreativeNonLinearAdsNonLinear.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMVastTrackingEvents.h"
#import "PBMVastResourceContainerProtocol.h"

@interface PBMVastCreativeNonLinearAdsNonLinear : NSObject <PBMVastResourceContainerProtocol>

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong, nonnull) PBMVastTrackingEvents *vastTrackingEvents;

@property (nonatomic, copy, nullable) NSString *clickThroughURI;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *clickTrackingURIs;

@property (nonatomic, copy, nullable) NSString *apiFramework;
@property (nonatomic, copy, nullable) NSString *identifier             NS_SWIFT_NAME(id);
@property (nonatomic, assign) BOOL scalable;
@property (nonatomic, assign) BOOL maintainAspectRatio;
@property (nonatomic, assign) NSTimeInterval minSuggestedDuration;
@property (nonatomic, assign) NSInteger assetWidth;
@property (nonatomic, assign) NSInteger assetHeight;

// PBMVastResourceContainer
@property (nonatomic, assign) PBMVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

@end
