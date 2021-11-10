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
