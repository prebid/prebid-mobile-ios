/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <XCTest/XCTest.h>
#import "PrebidMobileTests-Swift.h"

@interface PBMFunctionsPrivateTest : XCTestCase

@end

@implementation PBMFunctionsPrivateTest

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
    dispatch_time_t dispatchTime = [PBMFunctions dispatchTimeAfterTimeInterval:expectedWaitTime];

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
    dispatch_time_t dispatchTime = [PBMFunctions dispatchTimeAfterTimeInterval:expectedWaitTime startTime:DISPATCH_TIME_NOW];

    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^{
        NSTimeInterval actualWaitTime = [[NSDate date] timeIntervalSinceDate:startTime];
        XCTAssertGreaterThanOrEqual(actualWaitTime, expectedWaitTime);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:testTimeout handler:nil];
}

@end
