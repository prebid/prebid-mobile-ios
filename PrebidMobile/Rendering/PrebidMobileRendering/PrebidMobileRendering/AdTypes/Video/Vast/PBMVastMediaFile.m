//
//  PBMVastMediaFile.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastMediaFile.h"

#pragma mark - Implementation

@implementation PBMVastMediaFile

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        self.type = @"";
        self.mediaURI = @"";
    }
    
    return self;
}

- (void)setDeliver:(nullable NSString *) deliveryMode {
    self.streamingDeliver = [deliveryMode isEqualToString:@"streaming"];
}

@end
