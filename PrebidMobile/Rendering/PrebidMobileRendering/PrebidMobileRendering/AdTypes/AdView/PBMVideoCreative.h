//
//  PBMVideoCreative.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

//Superclass
#import "PBMAbstractCreative.h"
#import "PBMVideoViewDelegate.h"

@interface PBMVideoCreative : PBMAbstractCreative <PBMVideoViewDelegate>

@property (class, readonly) NSInteger maxSizeForPreRenderContent;

- (nonnull instancetype)initWithCreativeModel:(nonnull PBMCreativeModel *)creativeModel
                                  transaction:(nonnull PBMTransaction *)transaction
                                    videoData:(nonnull NSData *)data;

- (void)close;

- (BOOL)isPlaybackFinished;

@end
