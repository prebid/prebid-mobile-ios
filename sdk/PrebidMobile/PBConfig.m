/*   Copyright 2017 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#include "PBConfig.h"
#import "PBConstants.h"


@interface PBConfig ()

@end

@implementation PBConfig


- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

static PBConfig *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)resetSharedInstance {
    onceToken = 0;
    sharedInstance = nil;
}

- (nullable NSString *)priceGranularityForAuction {
    return [self priceGranularityForAuction: _priceGranularity];
}

- (nullable NSString *)priceGranularityForAuction:(PBPriceGranularity)priceGranularity {
    NSString *priceGranularityString = nil;
    switch (priceGranularity) {
        case PBPriceGranularityHigh:
            priceGranularityString = @"high";
            break;
        case PBPriceGranularityMedium:
            priceGranularityString = @"med";
            break;
        case PBPriceGranularityLow:
            priceGranularityString = @"low";
            break;
        case PBPriceGranularityDense:
            priceGranularityString = @"dense";
            break;
        case PBPriceGranularityAuto:
            priceGranularityString = @"auto";
            break;
        default:
            break;
    }
    
    return priceGranularityString;
}

@end
