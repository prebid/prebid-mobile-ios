//
//  OXMVastCreativeLinear.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastCreativeAbstract.h"
#import "OXMVastTrackingEvents.h"
#import "OXMVastMediaFile.h"
#import "OXMVastIcon.h"

//TODO: describe Vast XML structure

@interface OXMVastCreativeLinear : OXMVastCreativeAbstract

@property (nonatomic, strong, nonnull) NSMutableArray<OXMVastIcon *> *icons;
@property (nonatomic, strong, nullable) NSNumber *skipOffset;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong, nonnull) NSMutableArray<OXMVastMediaFile *> *mediaFiles;
@property (nonatomic, strong, nonnull) OXMVastTrackingEvents *vastTrackingEvents;

@property (nonatomic, copy, nullable) NSString *clickThroughURI;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *clickTrackingURIs;

- (nullable OXMVastMediaFile *)bestMediaFile;

@end
