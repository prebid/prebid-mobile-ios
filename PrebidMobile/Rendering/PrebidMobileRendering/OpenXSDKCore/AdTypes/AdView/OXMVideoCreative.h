//
//  OXMVideoCreative.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

//Superclass
#import "OXMAbstractCreative.h"
#import "OXMVideoViewDelegate.h"

@interface OXMVideoCreative : OXMAbstractCreative <OXMVideoViewDelegate>

@property (class, readonly) NSInteger maxSizeForPreRenderContent;

- (nonnull instancetype)initWithCreativeModel:(nonnull OXMCreativeModel *)creativeModel
                                  transaction:(nonnull OXMTransaction *)transaction
                                    videoData:(nonnull NSData *)data;

- (void)close;

- (BOOL)isPlaybackFinished;

@end
