//
//  OXMVastCreativeLinear.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastCreativeLinear.h"
#import "OXMConstants.h"

#pragma mark - Private Extension

@interface OXMVastCreativeLinear()

@property (nonatomic, strong, nullable) OXMVastMediaFile *myBestMediaFile;

@end

#pragma mark - Implementation

@implementation OXMVastCreativeLinear

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.skipOffset = nil;
        self.icons = [NSMutableArray array];
        self.mediaFiles = [NSMutableArray array];
        self.vastTrackingEvents = [[OXMVastTrackingEvents alloc] init];
        self.clickTrackingURIs = [NSMutableArray array];
    }
    
    return self;
}

- (OXMVastMediaFile *)bestMediaFile {
    OXMVastMediaFile *ret = nil;
    if (self.myBestMediaFile) {
        ret = self.myBestMediaFile;
    }
    else {
        NSMutableArray *eligableMediaFiles = [NSMutableArray array];
        for (OXMVastMediaFile *mediaFile in self.mediaFiles) {
            if ([OXMConstants.supportedVideoMimeTypes containsObject:mediaFile.type]) {
                [eligableMediaFiles addObject:mediaFile];
            }
        }
        
        // choose the one with the highest resolution that is acceptable
        if (eligableMediaFiles.count) {
            ret = [eligableMediaFiles firstObject];
            for (OXMVastMediaFile *mediaFile in eligableMediaFiles) {
                if (mediaFile.width * mediaFile.height > ret.width * ret.height) {
                    ret = mediaFile;
                }
            }
        }
    }
    
    return ret;
}

@end
