//
//  OXMFunctionsPrivateTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OpenXSDKCoreTests-Swift.h"

@interface OXMFunctionsPrivateTest : XCTestCase

@end

@implementation OXMFunctionsPrivateTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_dispatchTimeAfterTimeInterval {
    XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
    NSTimeInterval expectedWaitTime = 3;
    NSTimeInterval testTimeout = expectedWaitTime + 1;

    NSDate *startTime = [NSDate date];
    dispatch_time_t dispatchTime = [OXMFunctions dispatchTimeAfterTimeInterval:expectedWaitTime];

    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^{
        NSTimeInterval actualWaitTime = [[NSDate date] timeIntervalSinceDate:startTime];
        XCTAssertGreaterThanOrEqual(actualWaitTime, expectedWaitTime);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:testTimeout handler:nil];
}

- (void)test_dispatchTimeAfterTimeInterval_startTime {
    XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
    NSTimeInterval expectedWaitTime = 3;
    NSTimeInterval testTimeout = expectedWaitTime + 1;

    NSDate *startTime = [NSDate date];
    dispatch_time_t dispatchTime = [OXMFunctions dispatchTimeAfterTimeInterval:expectedWaitTime startTime:DISPATCH_TIME_NOW];

    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^{
        NSTimeInterval actualWaitTime = [[NSDate date] timeIntervalSinceDate:startTime];
        XCTAssertGreaterThanOrEqual(actualWaitTime, expectedWaitTime);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:testTimeout handler:nil];
}

@end
