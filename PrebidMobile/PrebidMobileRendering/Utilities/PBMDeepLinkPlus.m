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

#import "PBMDeepLinkPlus.h"
#import "NSURL+PBMExtensions.h"

@interface PBMDeepLinkPlus()

@property (nonatomic, strong, nonnull, readwrite) NSURL *primaryURL;
@property (nonatomic, strong, nullable, readwrite) NSURL *fallbackURL;
@property (nonatomic, strong, nullable, readwrite) NSArray<NSURL *> *primaryTrackingURLs;
@property (nonatomic, strong, nullable, readwrite) NSArray<NSURL *> *fallbackTrackingURLs;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

// MARK: -

@implementation PBMDeepLinkPlus

+ (nullable instancetype)deepLinkPlusWithURL:(NSURL *)url {
    PBMDeepLinkPlus * deepLinkPlus = [[PBMDeepLinkPlus alloc] init];
    if ([deepLinkPlus parseURL:url]) {
        return deepLinkPlus;
    } else {
        return nil;
    }
}

- (BOOL)parseURL:(NSURL * _Nonnull)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray<NSURLQueryItem *> *queryItems = [components queryItems];

    NSMutableArray<NSURL *> *primaryTrackingURLs = nil;
    NSMutableArray<NSURL *> *fallbackTrackingURLs = nil;

    for (NSURLQueryItem *queryItem in queryItems) {
        NSString *key = queryItem.name;
        NSURL *valueURL = [NSURL PBMURLWithoutEncodingFromString:queryItem.value];
        if (valueURL != nil) {
            if ([key isEqualToString:@"primaryUrl"]) {
                if (self.primaryURL == nil) {
                    self.primaryURL = valueURL;
                }
            } else if ([key isEqualToString:@"fallbackUrl"]) {
                if (self.fallbackURL == nil) {
                    self.fallbackURL = valueURL;
                }
            } else if ([key isEqualToString:@"primaryTrackingUrl"]) {
                if (primaryTrackingURLs == nil) {
                    primaryTrackingURLs = [[NSMutableArray alloc] init];
                }
                [primaryTrackingURLs addObject:valueURL];
            } else if ([key isEqualToString:@"fallbackTrackingUrl"]) {
                if (fallbackTrackingURLs == nil) {
                    fallbackTrackingURLs = [[NSMutableArray alloc] init];
                }
                [fallbackTrackingURLs addObject:valueURL];
            }
        }
    }
    self.primaryTrackingURLs = primaryTrackingURLs;
    self.fallbackTrackingURLs = fallbackTrackingURLs;
    return (self.primaryURL != nil);
}

@end
