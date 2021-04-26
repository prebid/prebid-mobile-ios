//
//  OXMLogObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PrebidMobileRenderingTests-Swift.h"

@interface PBMLogObjCTest : XCTestCase

@end

@implementation PBMLogObjCTest

- (void)tearDown {
    [UtilitiesForTesting releaseLogFile];
}

- (void)testLogObjCNilValues {
    [UtilitiesForTesting prepareLogFile];
    
    NSString *message = nil;
    [PBMLog logObjC:message
           logLevel:PBMLogLevelWarn
               file:nil
               line:0
           function:nil];
    
    NSString *log = [PBMLog.singleton getLogFileAsString];
    XCTAssert(log);
    XCTAssertTrue([log rangeOfString:@"WARNING"].location != NSNotFound);
}

@end
