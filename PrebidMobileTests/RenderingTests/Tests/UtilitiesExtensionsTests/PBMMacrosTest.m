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

@interface PBMMacrosTest : XCTestCase

@end

@implementation PBMMacrosTest

- (void)testWeakifyUnsafeifyStrongify {
    void (^verifyMemoryManagement)(void);
    
    @autoreleasepool {
        NSString *foo __attribute__((objc_precise_lifetime)) = [@"foo" mutableCopy];
        NSString *bar __attribute__((objc_precise_lifetime)) = [@"bar" mutableCopy];
        
        void *fooPtr = &foo;
        void *barPtr = &bar;
        
        @weakify(foo);
        @unsafeify(bar);
        
        BOOL (^matchesFooOrBar)(NSString *) = ^ BOOL (NSString *str){
            @strongify(foo);
            @strongify(bar);
            
            XCTAssertEqualObjects(foo, @"foo", @"");
            XCTAssertEqualObjects(bar, @"bar", @"");
            
            XCTAssertTrue(fooPtr != &foo, @"Address of 'foo' within block should be different from its address outside the block");
            XCTAssertTrue(barPtr != &bar, @"Address of 'bar' within block should be different from its address outside the block");
            
            return [foo isEqual:str] || [bar isEqual:str];
        };
        
        XCTAssertTrue(matchesFooOrBar(@"foo"), @"");
        XCTAssertTrue(matchesFooOrBar(@"bar"), @"");
        XCTAssertFalse(matchesFooOrBar(@"buzz"), @"");
        
        verifyMemoryManagement = [^{
            // Can only strongify the weak reference without issue.
            @strongify(foo);
            XCTAssertNil(foo, @"");
        } copy];
    }
    
    verifyMemoryManagement();
}

@end
