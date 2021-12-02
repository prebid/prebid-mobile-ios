//
//  OXMOpenMeasurementVideoVerificationParameters.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVideoVerificationParameters.h"

@implementation OXMVideoVerificationResource
@end

@implementation OXMVideoVerificationParameters

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        self.verificationResources = [NSMutableArray array];
        self.autoPlay = NO;
    }
    
    return self;
}


@end
