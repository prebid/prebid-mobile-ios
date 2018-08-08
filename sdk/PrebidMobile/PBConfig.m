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

@property (nonatomic, readwrite) BOOL isPriceGranularity;
@property (nonatomic, assign) PBPriceGranularity2 priceGranularity;

@end

@implementation PBConfig

- (instancetype)init {
    if (self = [super init]) {

        _isPriceGranularity = NO;
        
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

-(void) setPriceGranularity:(PBPriceGranularity2)priceGranularity{
    _priceGranularity = priceGranularity;
    NSLog(@"Antoine test Granularity is %ld", (long)_priceGranularity);
    self.isPriceGranularity = YES;
}

-(NSString *) priceGranularityF{
    if(self.isPriceGranularity){
        NSString *priceGranularityF = [self priceGranularityForAuction:_priceGranularity];
        NSLog(@"Antoine test Granularity2 is %@", priceGranularityF);
        return priceGranularityF;
    }
    return nil;
}

- (NSString *)priceGranularityForAuction:(PBPriceGranularity2)priceGranularity {
    NSString *_priceGranularity;
    switch (priceGranularity) {
        case PBPriceGranularityDense2:
            _priceGranularity = @"dense";
            break;
        case PBPriceGranularityUnknown2:
            _priceGranularity = @"unknown";
            break;
        default:
            _priceGranularity = @"medium";
            break;
    }
    
    return _priceGranularity;
}

@end
