//
//  PBMOpenMeasurementVideoVerificationParameters.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVideoVerificationParameters.h"

@implementation PBMVideoVerificationResource
@end

@implementation PBMVideoVerificationParameters

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        self.verificationResources = [NSMutableArray array];
        self.autoPlay = NO;
    }
    
    return self;
}


@end
