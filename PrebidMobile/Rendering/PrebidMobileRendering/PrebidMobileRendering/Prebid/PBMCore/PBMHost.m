/*   Copyright 2018-2021 Prebid.org, Inc.

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

#import "PBMError.h"
#import "PBMHost.h"

static const NSString * appnexusURL = @"https://prebid.adnxs.com/pbs/v1/openrtb2/auction";
static NSString * rubiconURL = @"https://prebid-server.rubiconproject.com/openrtb2/auction";

static PBMHost * _pbmSHostSingleton = nil;

@interface PBMHost()
@property (nonatomic, copy, nullable) NSString *prebidServerURL;
@end

@implementation PBMHost

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    return self;
}

// MARK: - Class properties

+ (PBMHost *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pbmSHostSingleton = [[PBMHost alloc] init];
    });
    return _pbmSHostSingleton;
}

- (void)setHostURL:(NSString *)hostURL {
    self.prebidServerURL = hostURL;
}

- (NSString *)getHostURL:(PBMPrebidHost)host error:(NSError* _Nullable __autoreleasing * _Nullable)error {
    switch(host) {
        case PBMPrebidHost_Appnexus:
            return [appnexusURL copy];
        case PBMPrebidHost_Rubicon:
            return [rubiconURL copy];
        case PBMPrebidHost_Custom:
            if ([self verifyUrl:self.prebidServerURL]) {
                if (error) {
                    *error = nil;
                }
                return self.prebidServerURL;
            } else {
                if (error) {
                    *error = [PBMError prebidServerURLInvalid:self.prebidServerURL];
                }
                return nil;
            }
    }
}

- (BOOL)verifyUrl:(NSString *)urlString {
    if (urlString == nil) {
        return NO;
    } else {
        const NSURL * url = [NSURL URLWithString:urlString];
        if (url == nil) {
            return NO;
        }
    }
    return YES;
}

@end
