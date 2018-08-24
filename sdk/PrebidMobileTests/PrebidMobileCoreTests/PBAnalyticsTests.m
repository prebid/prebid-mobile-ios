/*   Copyright 2017 Prebid.org, Inc.
 
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
#import "PBAnalyticsManager.h"
#import "PBMockAnalyticsService.h"
#import "PBAnalyticsEvent.h"

@interface PBAnalyticsManager ()

@property (atomic, strong) NSMutableSet *__nullable services;

@end

@interface PBAnalyticsTests : XCTestCase

@end

@implementation PBAnalyticsTests {
    PBMockAnalyticsService *_service;
    PBAnalyticsManager *_manager;
}

- (void)setUp {
    [super setUp];
    
    self->_manager = [PBAnalyticsManager sharedInstance];
    self->_service = [[PBMockAnalyticsService alloc] init];
    [_manager initializeWithApplication:nil launchOptions:nil];
    [self->_manager addService:self->_service];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testServiceAdd {
    XCTestExpectation *expectation = [self expectationWithDescription:@"add analytics service"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [expectation fulfill];
        XCTAssertTrue(self->_manager.services.count > 0);
    });
    [self waitForExpectationsWithTimeout:0.2 handler:nil];
}

- (void)testServiceRemove {
    XCTAssertTrue(_manager.services.count > 0);
    unsigned long count = self->_manager.services.count;
    XCTestExpectation *expectation = [self expectationWithDescription:@"remove analytics service"];
    [_manager removeService:_service];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [expectation fulfill];
        XCTAssertTrue(self->_manager.services.count <= (count - 1));
    });
    [self waitForExpectationsWithTimeout:0.2 handler:nil];
}

- (void)testEvent {
    PBAnalyticsEvent *event = [[PBAnalyticsEvent alloc] initWithEventType:PBAnalyticsEventRegisterAdUnit];
    XCTAssertEqual(event.type, PBAnalyticsEventRegisterAdUnit);
    XCTAssertNotEqual(event.type, PBAnalyticsEventAttachKeywords);
    XCTAssertNotEqual(event.type, PBAnalyticsEventRequestBids);
    XCTAssertNotNil(event.title);
}

@end
