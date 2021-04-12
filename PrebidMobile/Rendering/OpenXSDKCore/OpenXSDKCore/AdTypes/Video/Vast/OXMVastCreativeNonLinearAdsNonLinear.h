//
//  OXMVastCreativeNonLinearAdsNonLinear.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMVastTrackingEvents.h"
#import "OXMVastResourceContainerProtocol.h"

@interface OXMVastCreativeNonLinearAdsNonLinear : NSObject <OXMVastResourceContainerProtocol>

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong, nonnull) OXMVastTrackingEvents *vastTrackingEvents;

@property (nonatomic, copy, nullable) NSString *clickThroughURI;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *clickTrackingURIs;

@property (nonatomic, copy, nullable) NSString *apiFramework;
@property (nonatomic, copy, nullable) NSString *identifier             NS_SWIFT_NAME(id);
@property (nonatomic, assign) BOOL scalable;
@property (nonatomic, assign) BOOL maintainAspectRatio;
@property (nonatomic, assign) NSTimeInterval minSuggestedDuration;
@property (nonatomic, assign) NSInteger assetWidth;
@property (nonatomic, assign) NSInteger assetHeight;

// OXMVastResourceContainer
@property (nonatomic, assign) OXMVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

@end
