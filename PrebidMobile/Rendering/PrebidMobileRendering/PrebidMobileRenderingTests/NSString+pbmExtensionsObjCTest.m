//
//  NSString+PBMExtensionsObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

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
