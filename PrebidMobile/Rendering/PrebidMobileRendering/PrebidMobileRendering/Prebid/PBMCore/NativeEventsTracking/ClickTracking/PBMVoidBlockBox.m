//
//  PBMVoidBlockBox.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMVoidBlockBox.h"


@interface PBMVoidBlockBox ()
@property (nonatomic, strong, nonnull, readonly) PBMVoidBlock block;
@end



@implementation PBMVoidBlockBox

- (instancetype)initWithBlock:(PBMVoidBlock)block {
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
