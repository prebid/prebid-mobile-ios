//
//  PBMVastCreativeLinear.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastCreativeLinear.h"
#import "PBMConstants.h"

#pragma mark - Private Extension

@interface PBMVastCreativeLinear()

@property (nonatomic, strong, nullable) PBMVastMediaFile *myBestMediaFile;

@end

#pragma mark - Implementation

@implementation PBMVastCreativeLinear

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.skipOffset = nil;
        self.icons = [NSMutableArray array];
        self.mediaFiles = [NSMutableArray array];
        self.vastTrackingEvents = [[PBMVastTrackingEvents alloc] init];
        self.clickTrackingURIs = [NSMutableArray array];
    }
    
    return self;
}

- (PBMVastMediaFile *)bestMediaFile {
    PBMVastMediaFile *ret = nil;
    if (self.myBestMediaFile) {
        ret = self.myBestMediaFile;
    }
    else {
        NSMutableArray *eligableMediaFiles = [NSMutableArray array];
        for (PBMVastMediaFile *mediaFile in self.mediaFiles) {
            if ([PBMConstants.supportedVideoMimeTypes containsObject:mediaFile.type]) {
                [eligableMediaFiles addObject:mediaFile];
            }
        }
        
        // choose the one with the highest resolution that is acceptable
        if (eligableMediaFiles.count) {
            ret = [eligableMediaFiles firstObject];
            for (PBMVastMediaFile *mediaFile in eligableMediaFiles) {
                if (mediaFile.width * mediaFile.height > ret.width * ret.height) {
                    ret = mediaFile;
                }
            }
        }
    }
    
    return ret;
}

@end
