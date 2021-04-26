//
//  PBMAgeUtils.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMAgeUtils.h"

@implementation PBMAgeUtils

/*
 Returns the year of birthday for a given age
 */
+ (NSInteger)yobForAge:(NSInteger)age {
    //age to the year of birth (yob of Object: User on OpenRTB request)
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    return [components year] - age;
}

@end
