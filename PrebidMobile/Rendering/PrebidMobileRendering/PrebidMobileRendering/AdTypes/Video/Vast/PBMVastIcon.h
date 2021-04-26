//
//  PBMVastIcon.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMVastResourceContainerProtocol.h"

@interface PBMVastIcon : NSObject <PBMVastResourceContainerProtocol>

@property (nonatomic, copy, nonnull) NSString *program;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger xPosition;
@property (nonatomic, assign) NSInteger yPosition;

// optional
@property (nonatomic, assign) NSTimeInterval startOffset;
@property (nonatomic, assign) NSTimeInterval duration;


@property (nonatomic, copy, nullable) NSString *clickThroughURI;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *clickTrackingURIs;
@property (nonatomic, copy, nullable) NSString *viewTrackingURI;

// computed later
@property (nonatomic, assign) BOOL displayed;

// PBMVastResourceContainer
@property (nonatomic, assign) PBMVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

@end
