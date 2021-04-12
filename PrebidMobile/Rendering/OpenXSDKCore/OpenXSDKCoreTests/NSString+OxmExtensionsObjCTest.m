//
//  NSString+OXMExtensionsObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+OxmExtensions.h"

@interface NSString_OxmExtensionsObjCTest : XCTestCase

@end

@implementation NSString_OxmExtensionsObjCTest

- (void)testNilInput {
    NSString * const testString = @"abcd1234";
    NSString * nilString = nil;
    
    // OXMdoesMatch
    XCTAssertFalse([testString OXMdoesMatch:nilString]);
    
    // OXMnumberOfMatches
    XCTAssertEqual([testString OXMnumberOfMatches:nilString], 0);
 
    // OXMsubstringToString
    XCTAssertNil([testString OXMsubstringToString:nilString]);
    
    // OXMsubstringFromString
    XCTAssertNil([testString OXMsubstringFromString:nilString]);
    
    // OXMsubstringFromString:toString:
    XCTAssertNil([testString OXMsubstringFromString:@"abc" toString:nilString]);
    XCTAssertNil([testString OXMsubstringFromString:nilString toString:@"1234"]);
    XCTAssertNil([testString OXMsubstringFromString:nilString toString:nilString]);
    
    // OXMstringByReplacingRegex
    XCTAssertEqual([testString OXMstringByReplacingRegex:@"abc" replaceWith:nilString], testString);
    XCTAssertEqual([testString OXMstringByReplacingRegex:nilString replaceWith:@"xyz"], testString);
    XCTAssertEqual([testString OXMstringByReplacingRegex:nilString replaceWith:nilString], testString);
}

@end
