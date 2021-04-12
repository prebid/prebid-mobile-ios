//
//  XCTestCase+Throwing.h
//  OpenXInternalTestApp
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ObjcFailable
- (void)failTestWithMessage:(NSString *)message file:(NSString *)file line:(NSUInteger)line error:(NSError **)error;
@end



@interface XCTestCase (Throwing)
- (void)failIterationRunning;
- (BOOL)attemptRunningIteration:(void (NS_NOESCAPE ^)(void))runnable;
@end

NS_ASSUME_NONNULL_END
