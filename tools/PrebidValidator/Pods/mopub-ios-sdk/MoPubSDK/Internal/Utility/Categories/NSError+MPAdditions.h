//
//  NSError+MPAdditions.h
//  MoPubSDK
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (MPAdditions)

/**
 Queries if the error is a MoPub ad request timeout error.
 */
@property (nonatomic, readonly) BOOL isAdRequestTimedOutError;

@end
