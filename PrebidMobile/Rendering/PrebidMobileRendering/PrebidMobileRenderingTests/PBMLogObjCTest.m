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
    
    NSString *log = [PBMLog.shared getLogFileAsString];
    XCTAssert(log);
    XCTAssertTrue([log rangeOfString:@"WARNING"].location != NSNotFound);
}

@end
