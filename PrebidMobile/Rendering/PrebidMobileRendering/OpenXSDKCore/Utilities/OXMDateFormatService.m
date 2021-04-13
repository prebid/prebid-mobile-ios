//
//  OXMDateFormatService.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMDateFormatService.h"

#pragma mark - Private Extension

@interface OXMDateFormatService ()

@property (nonatomic, strong) NSDateFormatter *ISO8601FormatterUTC;
@property (nonatomic, strong) NSDateFormatter *ISO8601FormatterMRAID;

@end

#pragma mark - Implementation

@implementation OXMDateFormatService

#pragma mark - Private Initialization

+ (instancetype)singleton {
    static id singleton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[[self class] alloc] init];
    });
    
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ISO8601FormatterUTC = [NSDateFormatter new];
        self.ISO8601FormatterMRAID = [NSDateFormatter new];
        
        //Note that the single-quotes imply a string. ISO8601 dates do not have the quotes in them:
        //2015-07-30T02:26:54-0700
        self.ISO8601FormatterUTC.dateFormat     = @"yyyy-MM-dd'T'HH:mm:ssZZ";
        self.ISO8601FormatterMRAID.dateFormat   = @"yyyy-MM-dd'T'HH:mmZZ";
        
        self.ISO8601FormatterUTC.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        self.ISO8601FormatterMRAID.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    }
    
    return self;
}

#pragma mark - Public

- (NSDate *)formatISO8601ForString:(NSString *)strDate {
    if (!strDate || strDate.length < 17) {
        return nil;
    }
    
    const NSString *delimiter = [strDate substringWithRange:NSMakeRange(16, 1)];
    if ([delimiter isEqualToString:@":"]) {
        //There is a seconds field. Use _ISO8601FormatterUTC
        return [self.ISO8601FormatterUTC dateFromString:strDate];
    }
    
    //No seconds field. Use _ISO8601FormatterMRAID
    return [self.ISO8601FormatterMRAID dateFromString:strDate];
}

@end
