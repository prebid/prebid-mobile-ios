//
//  OXMLogObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OpenXSDKCoreTests-Swift.h"

@interface OXMLogObjCTest : XCTestCase

@end

@implementation OXMLogObjCTest

- (void)tearDown {
    [UtilitiesForTesting releaseLogFile];
}

- (void)testLogObjCNilValues {
    [UtilitiesForTesting prepareLogFile];
    
    NSString *message = nil;
    [OXMLog logObjC:message
           logLevel:OXALogLevelWarn
               file:nil
               line:0
           function:nil];
    
    NSString *log = [OXMLog.singleton getLogFileAsString];
    XCTAssert(log);
    XCTAssertTrue([log rangeOfString:@"WARNING"].location != NSNotFound);
}

@end
