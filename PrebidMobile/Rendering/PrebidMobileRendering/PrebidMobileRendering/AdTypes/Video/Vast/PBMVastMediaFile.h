//
//  PBMVastMediaFile.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBMVastMediaFile : NSObject

@property (nonatomic, assign) BOOL streamingDeliver;
@property (nonatomic, copy, nonnull) NSString *type;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, copy, nonnull) NSString *mediaURI;

@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *codec;
@property (nonatomic, copy, nullable) NSString *deivery;
@property (nonatomic, copy, nullable) NSNumber *bitrate;
@property (nonatomic, copy, nullable) NSNumber *minBitrate;
@property (nonatomic, copy, nullable) NSNumber *maxBitrate;
@property (nonatomic, copy, nullable) NSNumber *scalable;
@property (nonatomic, copy, nullable) NSNumber *maintainAspectRatio;
@property (nonatomic, copy, nullable) NSString *apiFramework;

- (nonnull instancetype)init;

- (void)setDeliver:(nullable NSString *) deliveryMode;

@end
