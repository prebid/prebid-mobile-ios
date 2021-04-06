//
//  NSMutableDictionaryTests.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSMutableDictionary+OxmExtensions.h"

@interface NSMutableDictionaryTests : XCTestCase

@end

@implementation NSMutableDictionaryTests


- (void)testOxmRemoveEmptyVals {
    NSMutableDictionary * const initial = [NSMutableDictionary new];
    NSMutableDictionary * const filtered = [initial oxmCopyWithoutEmptyVals];
    
    XCTAssertNotNil(filtered);
    XCTAssertEqual(filtered.count, 0);
    XCTAssertEqualObjects(initial, filtered);
    XCTAssertNotEqual(filtered, initial);
     
    NSMutableDictionary * const initialFullValues = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"2" : @"2", @"3" : @"3"}];
    NSMutableDictionary * const expectedFullValues = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"2" : @"2", @"3" : @"3"}];
    XCTAssertEqualObjects([initialFullValues oxmCopyWithoutEmptyVals], expectedFullValues);
    NSMutableDictionary * const filteredFullValues = [initialFullValues mutableCopy];
    [filteredFullValues oxmRemoveEmptyVals];
    XCTAssertEqualObjects(filteredFullValues, expectedFullValues);
    
    NSMutableDictionary * const initialValuesWithNil = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"2" : [NSNull new], @"3" : @"3"}];
    NSMutableDictionary * const expectedValuesWithNil  = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"3" : @"3"}];
    XCTAssertEqualObjects(expectedValuesWithNil, [initialValuesWithNil oxmCopyWithoutEmptyVals]);
    NSMutableDictionary * const filteredValuesWithNil = [initialFullValues mutableCopy];
    [filteredValuesWithNil oxmRemoveEmptyVals];
    XCTAssertEqualObjects(filteredValuesWithNil, expectedFullValues);
    
    NSMutableDictionary * const initialValuesWithArray = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"2" : @[@"2"], @"3" : @"3"}];
    NSMutableDictionary * const expectedValuesWithArray  = [[NSMutableDictionary alloc] initWithDictionary:@{@"1" : @"1", @"2" : @[@"2"], @"3" : @"3"}];
    XCTAssertEqualObjects(expectedValuesWithArray, [initialValuesWithArray oxmCopyWithoutEmptyVals]);
    NSMutableDictionary * const filteredValuesWithArray = [initialFullValues mutableCopy];
    [filteredValuesWithArray oxmRemoveEmptyVals];
    XCTAssertEqualObjects(filteredValuesWithArray, expectedFullValues);
    
    NSMutableDictionary * const initialValuesWithEmptyArray = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"2" : @[], @"3" : @"3"}];
    NSMutableDictionary * const expectedValuesWithEmptyArray  = [[NSMutableDictionary alloc] initWithDictionary:@{@"1" : @"1", @"2" : @[], @"3" : @"3"}];
    XCTAssertEqualObjects(expectedValuesWithEmptyArray, [initialValuesWithEmptyArray oxmCopyWithoutEmptyVals]);
    NSMutableDictionary * const filteredValuesWithEmptyArray = [initialFullValues mutableCopy];
    [filteredValuesWithEmptyArray oxmRemoveEmptyVals];
    XCTAssertEqualObjects(filteredValuesWithEmptyArray, expectedFullValues);
}



@end
