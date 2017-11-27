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

#import "PBServerHost.h"
#import <XCTest/XCTest.h>

@interface PBServerHostTests : XCTestCase

@end

@implementation PBServerHostTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [PBServerHost resetSharedInstance];
    [super tearDown];
}

- (void)testSetHost {
    // Test default host
    XCTAssertEqual(PBSHostAppNexus, [[PBServerHost sharedInstance] pbsHost]);
    
    [[PBServerHost sharedInstance] setPbsHost:PBSHostRubicon];
    XCTAssertEqual(PBSHostRubicon, [[PBServerHost sharedInstance] pbsHost]);
    [[PBServerHost sharedInstance] setPbsHost:PBSHostAppNexus];
    XCTAssertEqual(PBSHostAppNexus, [[PBServerHost sharedInstance] pbsHost]);
}

@end
