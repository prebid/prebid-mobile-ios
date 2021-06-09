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
#import "NSString+PBMExtensions.h"

@interface NSString_PBMExtensionsObjCTest : XCTestCase

@end

@implementation NSString_PBMExtensionsObjCTest

- (void)testNilInput {
    NSString * const testString = @"abcd1234";
    NSString * nilString = nil;
    
    // PBMdoesMatch
    XCTAssertFalse([testString PBMdoesMatch:nilString]);
    
    // PBMnumberOfMatches
    XCTAssertEqual([testString PBMnumberOfMatches:nilString], 0);
 
    // PBMsubstringToString
    XCTAssertNil([testString PBMsubstringToString:nilString]);
    
    // PBMsubstringFromString
    XCTAssertNil([testString PBMsubstringFromString:nilString]);
    
    // PBMsubstringFromString:toString:
    XCTAssertNil([testString PBMsubstringFromString:@"abc" toString:nilString]);
    XCTAssertNil([testString PBMsubstringFromString:nilString toString:@"1234"]);
    XCTAssertNil([testString PBMsubstringFromString:nilString toString:nilString]);
    
    // PBMstringByReplacingRegex
    XCTAssertEqual([testString PBMstringByReplacingRegex:@"abc" replaceWith:nilString], testString);
    XCTAssertEqual([testString PBMstringByReplacingRegex:nilString replaceWith:@"xyz"], testString);
    XCTAssertEqual([testString PBMstringByReplacingRegex:nilString replaceWith:nilString], testString);
}

@end
