//
//  MPVASTTrackingEvent.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTTrackingEvent.h"
#import "MPVASTDurationOffset.h"

@implementation MPVASTTrackingEvent

#pragma mark - MPVASTModel Overrides

- (instancetype _Nullable)initWithDictionary:(NSDictionary<NSString *, id> * _Nullable)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        _eventType = dictionary[@"event"];

        _URL = [self generateModelFromDictionaryValue:dictionary
                                        modelProvider:^id(NSDictionary *dictionary) {
            // Extract the tracking URL string from the CDATA text.
            NSString *urlString = [dictionary[@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            // Make sure that NSURL doesn't receive a `nil` string.
            return (urlString != nil ? [NSURL URLWithString:urlString] : nil);
        }];
        // a tracker that does not specify a URL is not valid
        if (_URL == nil) {
            return nil;
        }

        _progressOffset = [self generateModelFromDictionaryValue:dictionary
                                                   modelProvider:^id(NSDictionary *dictionary) {
            return [[MPVASTDurationOffset alloc] initWithDictionary:dictionary];
        }];
    }
    return self;
}

#pragma mark - Initialization

- (instancetype _Nullable)initWithEventType:(MPVideoEvent)eventType
                                        url:(NSURL *)url
                             progressOffset:(MPVASTDurationOffset * _Nullable)progressOffset {
    // a tracker that does not specify a URL is not valid
    if (url == nil) {
        return nil;
    }

    // Initialize with an empty dictionary instead of a `nil` dictionary since we want
    // `self` to initialize.
    self = [super initWithDictionary:@{}];
    if (self) {
        _eventType = eventType;
        _URL = url;
        _progressOffset = progressOffset;
    }
    return self;
}

@end
