//
//  OXMDeepLinkPlus.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMDeepLinkPlus.h"

@interface OXMDeepLinkPlus()

@property (nonatomic, strong, nonnull, readwrite) NSURL *primaryURL;
@property (nonatomic, strong, nullable, readwrite) NSURL *fallbackURL;
@property (nonatomic, strong, nullable, readwrite) NSArray<NSURL *> *primaryTrackingURLs;
@property (nonatomic, strong, nullable, readwrite) NSArray<NSURL *> *fallbackTrackingURLs;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

// MARK: -

@implementation OXMDeepLinkPlus

+ (nullable instancetype)deepLinkPlusWithURL:(NSURL *)url {
    OXMDeepLinkPlus * deepLinkPlus = [[OXMDeepLinkPlus alloc] init];
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
        NSURL *valueURL = [NSURL URLWithString:queryItem.value];
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
