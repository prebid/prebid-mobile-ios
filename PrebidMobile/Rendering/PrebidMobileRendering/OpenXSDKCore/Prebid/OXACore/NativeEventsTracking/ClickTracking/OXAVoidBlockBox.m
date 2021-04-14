//
//  OXAVoidBlockBox.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAVoidBlockBox.h"


@interface OXAVoidBlockBox ()
@property (nonatomic, strong, nonnull, readonly) OXMVoidBlock block;
@end



@implementation OXAVoidBlockBox

- (instancetype)initWithBlock:(OXMVoidBlock)block {
    if (!(self = [super init])) {
        return nil;
    }
    _block = block;
    return self;
}

- (void)invoke {
    self.block();
}

@end
