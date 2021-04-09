//
//  OXANativeClickTrackingEntry.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeClickTrackingEntry.h"
#import "OXMMacros.h"


@interface OXANativeClickTrackingEntry ()
@property (nonatomic, strong, nonnull, readonly) OXMVoidBlock detachmentBlock;
@end



@implementation OXANativeClickTrackingEntry

- (void)dealloc {
    self.detachmentBlock();
}

- (instancetype)initWithView:(UIView *)view
                 clickBinder:(OXANativeClickTrackerBinderBlock)clickBinderBlock
                clickHandler:(OXANativeClickHandlerBlock)clickHandlerBlock
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
