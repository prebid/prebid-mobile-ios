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

@interface LogObjCTest : XCTestCase

@end

@implementation LogObjCTest

- (void)tearDown {
    [UtilitiesForTesting releaseLogFile];
}

- (void)testLogError {
    [UtilitiesForTesting prepareLogFile];
    
    LogError(@"Test Log");
    
    NSString *log = [Log getLogFileAsString];
    XCTAssert(log);
    XCTAssertTrue([log containsString:@"Test Log"]);
    XCTAssertTrue([log containsString:LogLevel.error.stringValue]);
}

- (void)testLogDebug {
    [UtilitiesForTesting prepareLogFile];
    
    LogDebug(@"Test Log");
    
    NSString *log = [Log getLogFileAsString];
    XCTAssert(log);
    XCTAssertTrue([log containsString:@"Test Log"]);
    XCTAssertTrue([log containsString:LogLevel.debug.stringValue]);
}

- (void)testLogInfo {
    [UtilitiesForTesting prepareLogFile];
    
    LogInfo(@"Test Log");
    
    NSString *log = [Log getLogFileAsString];
    XCTAssert(log);
    XCTAssertTrue([log containsString:@"Test Log"]);
    XCTAssertTrue([log containsString:LogLevel.info.stringValue]);
}

- (void)testLogVerbose {
    [UtilitiesForTesting prepareLogFile];
    
    LogVerbose(@"Test Log");
    
    NSString *log = [Log getLogFileAsString];
    XCTAssert(log);
    XCTAssertTrue([log containsString:@"Test Log"]);
    XCTAssertTrue([log containsString:LogLevel.verbose.stringValue]);
}

- (void)testLogWarn {
    [UtilitiesForTesting prepareLogFile];
    
    LogWarn(@"Test Log");
    
    NSString *log = [Log getLogFileAsString];
    XCTAssert(log);
    XCTAssertTrue([log containsString:@"Test Log"]);
    XCTAssertTrue([log containsString:LogLevel.warn.stringValue]);
}

- (void)testLogSevere {
    [UtilitiesForTesting prepareLogFile];
    
    LogSevere(@"Test Log");
    
    NSString *log = [Log getLogFileAsString];
    XCTAssert(log);
    XCTAssertTrue([log containsString:@"Test Log"]);
    XCTAssertTrue([log containsString:LogLevel.severe.stringValue]);
}

- (void)testLogWhereAmI {
    [UtilitiesForTesting prepareLogFile];
    
    LogWhereAmI()
    
    NSString *log = [Log getLogFileAsString];
    XCTAssert(log);
    XCTAssertTrue([log containsString:LogLevel.info.stringValue]);
}

@end
