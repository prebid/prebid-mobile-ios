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
#import "NSMutableDictionary+PBMExtensions.h"

@interface NSMutableDictionaryTests : XCTestCase

@end

@implementation NSMutableDictionaryTests

- (void)testPBMRemoveEmptyVals {
    NSMutableDictionary * const initial = [NSMutableDictionary new];
    NSMutableDictionary * const filtered = [initial pbmCopyWithoutEmptyVals];
    
    XCTAssertNotNil(filtered);
    XCTAssertEqual(filtered.count, 0);
    XCTAssertEqualObjects(initial, filtered);
    XCTAssertNotEqual(filtered, initial);
     
    NSMutableDictionary * const initialFullValues = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"2" : @"2", @"3" : @"3"}];
    NSMutableDictionary * const expectedFullValues = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"2" : @"2", @"3" : @"3"}];
    XCTAssertEqualObjects([initialFullValues pbmCopyWithoutEmptyVals], expectedFullValues);
    NSMutableDictionary * const filteredFullValues = [initialFullValues mutableCopy];
    [filteredFullValues pbmRemoveEmptyVals];
    XCTAssertEqualObjects(filteredFullValues, expectedFullValues);
    
    NSMutableDictionary * const initialValuesWithNil = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"2" : [NSNull new], @"3" : @"3"}];
    NSMutableDictionary * const expectedValuesWithNil  = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"3" : @"3"}];
    XCTAssertEqualObjects(expectedValuesWithNil, [initialValuesWithNil pbmCopyWithoutEmptyVals]);
    NSMutableDictionary * const filteredValuesWithNil = [initialFullValues mutableCopy];
    [filteredValuesWithNil pbmRemoveEmptyVals];
    XCTAssertEqualObjects(filteredValuesWithNil, expectedFullValues);
    
    NSMutableDictionary * const initialValuesWithArray = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"2" : @[@"2"], @"3" : @"3"}];
    NSMutableDictionary * const expectedValuesWithArray  = [[NSMutableDictionary alloc] initWithDictionary:@{@"1" : @"1", @"2" : @[@"2"], @"3" : @"3"}];
    XCTAssertEqualObjects(expectedValuesWithArray, [initialValuesWithArray pbmCopyWithoutEmptyVals]);
    NSMutableDictionary * const filteredValuesWithArray = [initialFullValues mutableCopy];
    [filteredValuesWithArray pbmRemoveEmptyVals];
    XCTAssertEqualObjects(filteredValuesWithArray, expectedFullValues);
    
    NSMutableDictionary * const initialValuesWithEmptyArray = [[NSMutableDictionary alloc] initWithDictionary: @{@"1" : @"1", @"2" : @[], @"3" : @"3"}];
    NSMutableDictionary * const expectedValuesWithEmptyArray  = [[NSMutableDictionary alloc] initWithDictionary:@{@"1" : @"1", @"2" : @[], @"3" : @"3"}];
    XCTAssertEqualObjects(expectedValuesWithEmptyArray, [initialValuesWithEmptyArray pbmCopyWithoutEmptyVals]);
    NSMutableDictionary * const filteredValuesWithEmptyArray = [initialFullValues mutableCopy];
    [filteredValuesWithEmptyArray pbmRemoveEmptyVals];
    XCTAssertEqualObjects(filteredValuesWithEmptyArray, expectedFullValues);
}

@end
