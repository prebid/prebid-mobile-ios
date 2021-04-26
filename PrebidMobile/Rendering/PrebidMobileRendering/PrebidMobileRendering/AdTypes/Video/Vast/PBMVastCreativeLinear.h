//
//  PBMVastCreativeLinear.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastCreativeAbstract.h"
#import "PBMVastTrackingEvents.h"
#import "PBMVastMediaFile.h"
#import "PBMVastIcon.h"

//TODO: describe Vast XML structure

@interface PBMVastCreativeLinear : PBMVastCreativeAbstract

@property (nonatomic, strong, nonnull) NSMutableArray<PBMVastIcon *> *icons;
@property (nonatomic, strong, nullable) NSNumber *skipOffset;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong, nonnull) NSMutableArray<PBMVastMediaFile *> *mediaFiles;
@property (nonatomic, strong, nonnull) PBMVastTrackingEvents *vastTrackingEvents;

@property (nonatomic, copy, nullable) NSString *clickThroughURI;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *clickTrackingURIs;

- (nullable PBMVastMediaFile *)bestMediaFile;

@end
