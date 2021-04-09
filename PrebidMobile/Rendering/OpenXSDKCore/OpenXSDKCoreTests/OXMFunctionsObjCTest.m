//
//  TestOXMFunctionsObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OXMFunctions+Private.h"

@interface OXMFunctionsObjCTest : XCTestCase

@end

@implementation OXMFunctionsObjCTest

#pragma mark - JSON

- (void)testDictionaryFromDataWithNilData {
    
    NSData *data = nil;
    NSError *error = nil;
    
    OXMJsonDictionary *dict = [OXMFunctions dictionaryFromData:data error:&error];
    
    XCTAssertNil(dict);
    XCTAssertNotNil(error);
    XCTAssert([error.localizedDescription rangeOfString:@"Invalid JSON data"].location != NSNotFound);
}

- (void)testDictionaryFromJSONStringWithNilString {
    
    NSString *jsonString = nil;
    NSError *error = nil;
    
    OXMJsonDictionary *dict = [OXMFunctions dictionaryFromJSONString:jsonString error:&error];
    
    XCTAssertNil(dict);
    XCTAssertNotNil(error);
    XCTAssert([error.localizedDescription rangeOfString:@"Could not convert jsonString to data: (null)"].location != NSNotFound);
}

- (void)testToStringJsonDictionaryWithNilJSON {
    
    OXMJsonDictionary *jsonDict = nil;
    NSError *error = nil;
    NSString *jsonString = [OXMFunctions toStringJsonDictionary:jsonDict error:&error];
    
    XCTAssertNil(jsonString);
    XCTAssertNotNil(error);
    XCTAssert([error.localizedDescription rangeOfString:@"Not valid JSON object: (null)"].location != NSNotFound);
}

@end
