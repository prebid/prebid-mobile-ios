//
//  AFCuePoint.h
//  AdformAdvertising
//
//  Created by Vladas Drejeris on 30/03/16.
//  Copyright © 2016 adform. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Cue point describes a place intended for ad in video.
 */
@interface AFCuePoint : NSObject <NSCopying>

/**
 A time at which the ad may be displayed.
 */
@property (nonatomic, assign) NSTimeInterval time;

/**
 An identifier for the cue point.
 */
@property (nonatomic, assign) NSInteger identifier;

/**
 Creates a new instance of AFCuePoint with privided time and identifier.
 
 @param time A time at which the ad may be shown.
 @param identifier An identifier for a cue point.
 
 @return A newlly created AFCuePoint instance.
 */
- (instancetype)initWithTime:(NSTimeInterval )time identifier:(NSInteger )identifier;

@end
