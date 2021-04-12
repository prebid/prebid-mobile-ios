//
//  XCTestCase+Throwing.m
//  OpenXInternalTestApp
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "XCTestCase+Throwing.h"
 
static NSString * const iterationExceptionName = @"UITest Iteration Exception";

@implementation XCTestCase (Throwing)

- (void)failIterationRunning {
    NSException *myException = [NSException exceptionWithName:iterationExceptionName
                                                       reason:iterationExceptionName
                                                     userInfo:nil];
    @throw myException;
}

- (BOOL)attemptRunningIteration:(void (NS_NOESCAPE ^)(void))runnable {
    @try {
        runnable();
        return YES;
    }
    @catch (NSException *e) {
        if([e.name isEqualToString:iterationExceptionName]) {
            return NO;
        } else {
            @throw e;
        }
    }
}

@end
