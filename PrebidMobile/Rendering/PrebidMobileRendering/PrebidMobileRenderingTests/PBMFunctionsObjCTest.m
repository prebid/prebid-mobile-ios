//
//  TestPBMFunctionsObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>

//FIXME: impport PBMFunctions+Private.h causes the redifinition error for PBMLocationSourceValues,...
//Update this test after migration to Swift
//#import "PBMFunctions+Private.h"

@interface PBMFunctionsObjCTest : XCTestCase

@end

@implementation PBMFunctionsObjCTest

#pragma mark - JSON

- (void)testDictionaryFromDataWithNilData {
    /*
    NSData *data = nil;
    NSError *error = nil;
    
    PBMJsonDictionary *dict = [PBMFunctions dictionaryFromData:data error:&error];
    
    XCTAssertNil(dict);
    XCTAssertNotNil(error);
    XCTAssert([error.localizedDescription rangeOfString:@"Invalid JSON data"].location != NSNotFound);
     */
}

- (void)testDictionaryFromJSONStringWithNilString {
    /*
    NSString *jsonString = nil;
    NSError *error = nil;
    
    PBMJsonDictionary *dict = [PBMFunctions dictionaryFromJSONString:jsonString error:&error];
    
    XCTAssertNil(dict);
    XCTAssertNotNil(error);
    XCTAssert([error.localizedDescription rangeOfString:@"Could not convert jsonString to data: (null)"].location != NSNotFound);
     */
}

- (void)testToStringJsonDictionaryWithNilJSON {
    /*
    PBMJsonDictionary *jsonDict = nil;
    NSError *error = nil;
    NSString *jsonString = [PBMFunctions toStringJsonDictionary:jsonDict error:&error];
    
    XCTAssertNil(jsonString);
    XCTAssertNotNil(error);
    XCTAssert([error.localizedDescription rangeOfString:@"Not valid JSON object: (null)"].location != NSNotFound);
     */
}

@end
