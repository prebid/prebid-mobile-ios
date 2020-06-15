/*   Copyright 2018-2019 Prebid.org, Inc.

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

#import "ExAdUnit.h"

@implementation ExAdUnit

+ (void)load {
    [NSObject exchangeInstanceCls1:[AdUnit class] Sel1:@selector(fetchDemandWithAdObject:completion:) Cls2:[self class] Sel2:@selector(swizzledFetchDemandWithAdObject:completion:)];
    [NSObject exchangeInstanceCls1:[AdUnit class] Sel1:@selector(fetchDemandWithCompletion:) Cls2:[self class] Sel2:@selector(swizzledFetchDemandWithCompletion:)];
}

+ (instancetype)shared
{
    static ExAdUnit *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ExAdUnit alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(id)init {
     if (self = [super init])  {
         self.adUnit = [[BannerAdUnit alloc] initWithConfigId:@"1001-1" size:CGSizeMake(300, 250)];
         
     }
     return self;
}

-(void)swizzledFetchDemandWithAdObject: (NSObject*)adObject completion:(void (^) (ResultCode))block  {
    block(ResultCodePrebidDemandFetchSuccess);
}

-(void) swizzledFetchDemandWithCompletion: (void (^) (ResultCode, NSDictionary*))block {
    block(ResultCodePrebidDemandFetchSuccess, @{@"key1" : @"value1"});
}

@end
