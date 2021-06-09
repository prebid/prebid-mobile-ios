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

#import "PBMNativeAdImpressionReporting.h"
#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>


@implementation PBMNativeAdImpressionReporting

+ (PBMNativeImpressionDetectionHandler)impressionReporterWithEventTrackers:(NSArray<PBMNativeAdMarkupEventTracker *> *)eventTrackers
                                                                urlVisitor:(PBMTrackingURLVisitorBlock)urlVisitor
                                                          
{
    return ^(NSInteger impressionType) {
        if (eventTrackers.count <= 0) {
            return;
        }
        NSMutableArray <NSString *> * const trackingUrls = [[NSMutableArray alloc] initWithCapacity:eventTrackers.count];
        for (PBMNativeAdMarkupEventTracker *nextEventTracker in eventTrackers) {
            if (nextEventTracker.event == impressionType
                && nextEventTracker.method == NativeEventTrackingMethodImg
                && nextEventTracker.url != nil)
            {
                [trackingUrls addObject:nextEventTracker.url];
            }
        }
        urlVisitor(trackingUrls);
    };
}

@end
