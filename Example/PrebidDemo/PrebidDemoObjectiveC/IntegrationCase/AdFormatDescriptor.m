/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

#import <Foundation/Foundation.h>
#import "AdFormatDescriptor.h"

@implementation AdFormatDescriptor

+ (NSString *)getDescriptionForAdFormat:(AdFormat)adFormat {
    switch(adFormat) {
        case AdFormatDisplayBanner:
            return @"Display Banner";
        case AdFormatVideoBanner:
            return @"Video Banner";
        case AdFormatNativeBanner:
            return @"Native Banner";
        case AdFormatDisplayInterstitial:
            return @"Display Interstitial";
        case AdFormatVideoInterstitial:
            return @"Video Interstitial";
        case AdFormatDisplayRewarded:
            return @"Display Rewarded";
        case AdFormatVideoRewarded:
            return @"Video Rewarded";
        case AdFormatVideoInstream:
            return @"Video In-stream";
        case AdFormatNative:
            return @"Native";
        case AdFormatMultiformat:
            return @"Multiformat";
        case AdFormatAll:
            return @"All";
    }
}
@end
