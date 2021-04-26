//
//  PBMNativeClickTrackingEntry.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeClickTrackingEntry.h"
#import "PBMMacros.h"


@interface PBMNativeClickTrackingEntry ()
@property (nonatomic, strong, nonnull, readonly) PBMVoidBlock detachmentBlock;
@end



@implementation PBMNativeClickTrackingEntry

- (void)dealloc {
    self.detachmentBlock();
}

- (instancetype)initWithView:(UIView *)view
                 clickBinder:(PBMNativeClickTrackerBinderBlock)clickBinderBlock
                clickHandler:(PBMNativeClickHandlerBlock)clickHandlerBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    _trackedView = view;
    @weakify(self);
    _detachmentBlock = clickBinderBlock(^{
        @strongify(self);
        if (self == nil) {
            return;
        }
        clickHandlerBlock(self);
    });
    return self;
}

@end
