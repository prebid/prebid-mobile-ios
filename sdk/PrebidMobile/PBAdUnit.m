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

#import "PBAdUnit.h"

@interface PBAdUnit ()

#pragma mark Properties
@property (nonatomic, readwrite, strong) NSString *__nonnull uuid;
@property (nonatomic, readwrite, strong) NSString *__nonnull identifier;
@property (nonatomic, readwrite, strong) NSString *__nonnull configId;
@property (nonatomic, readwrite, strong) NSMutableArray<CGSize> *__nullable adSizes;

@property (nonatomic, assign) PBAdUnitType adType;
@property (nonatomic, assign) NSTimeInterval timeToExpireAllBids;

@end

@implementation PBAdUnit

#pragma mark Initialization
- (nonnull instancetype)initWithIdentifier:(nonnull NSString *)identifier andAdType:(PBAdUnitType)type andConfigId:(nonnull NSString *)configId {
    if ((self = [super init])) {
        [self generateUUID];
        _identifier = [identifier copy];
        _adType = type;
        _timeToExpireAllBids = 0;
        _configId = configId;
        _isSecure = false;
    }
    return (self);
}

#pragma mark Methods
- (NSArray<CGSize> *)adSizes {
    return _adSizes;
}

- (void)addSize:(CGSize)adSize {
    if (_adSizes == nil) {
        _adSizes = [[NSMutableArray<CGSize> alloc] init];
    }
    [_adSizes addObject:[NSValue valueWithCGSize:adSize]];
}

- (void)setAdUnitType:(PBAdUnitType)type {
    _adType = type;
}

- (void)generateUUID {
    _uuid = [[NSUUID UUID] UUIDString];
}

- (BOOL)shouldExpireAllBids:(NSTimeInterval)currentTime {
    return currentTime > self.timeToExpireAllBids;
}

- (void)setTimeIntervalToExpireAllBids:(NSTimeInterval)expiryTime {
    if (expiryTime > self.timeToExpireAllBids) {
        self.timeToExpireAllBids = expiryTime;
    }
}

- (BOOL)isEqualToAdUnit:(PBAdUnit *)otherAdUnit {
    return [self.identifier isEqualToString:otherAdUnit.identifier];
}

@end
