//
//  PBMDateFormatService.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(DateFormatService)
@interface PBMDateFormatService : NSObject

+ (instancetype)singleton;

- (NSDate *)formatISO8601ForString:(NSString *)strDate
    NS_SWIFT_NAME(formatISO8601(strDate:));

@end
