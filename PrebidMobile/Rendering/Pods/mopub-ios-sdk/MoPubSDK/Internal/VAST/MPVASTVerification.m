//
//  MPVASTVerification.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTVerification.h"

@implementation MPVASTVerification

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        NSArray *trackingEvents = [self generateModelsFromDictionaryValue:dictionary[@"TrackingEvents"][@"Tracking"]
                                                            modelProvider:^id(NSDictionary *dictionary) {
                                                                return [[MPVASTTrackingEvent alloc] initWithDictionary:dictionary];
                                                            }];
        NSMutableDictionary<NSString *, NSMutableArray<MPVASTTrackingEvent *> *> *eventsDictionary = [NSMutableDictionary dictionary];
        for (MPVASTTrackingEvent *event in trackingEvents) {
            NSMutableArray *events = [eventsDictionary objectForKey:event.eventType];
            if (!events) {
                [eventsDictionary setObject:[NSMutableArray array] forKey:event.eventType];
                events = [eventsDictionary objectForKey:event.eventType];
            }
            [events addObject:event];
        }
        _trackingEvents = eventsDictionary;
    }
    return self;
}

+ (NSDictionary *)modelMap {
    return @{
        @"javascriptResource":     @[@"JavaScriptResource", MPParseClass([MPVASTJavaScriptResource class])],
        @"vendor":                 @"vendor",
        @"verificationParameters": @"VerificationParameters.text",
    };
}

@end
