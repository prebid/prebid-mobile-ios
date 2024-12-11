/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

import XCTest
@testable import PrebidMobile

class ArbitraryORTBServiceTests: XCTestCase {
    
    func testMerge_BothGlobalAndImpORTBAreEmpty() {
        let sdkORTB: [String: Any] = [
            "user": ["id": "user123"]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: nil
        )
        
        let expectedORTB = """
        {
            "user": {
                "id": "user123"
            }
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithImp_emptyGlobal() {
        let impORTB = "{\"banner\": {\"format\": [{\"w\": 300, \"h\": 250}]}}"
        let sdkORTB = "{\"imp\": [{\"id\": \"1\", \"banner\": {\"format\": [{\"w\": 320, \"h\": 50}]}}]}"
        let expectedORTB = "{\"imp\": [{\"id\": \"1\", \"banner\": {\"format\": [{\"w\": 320, \"h\": 50},{\"w\": 300, \"h\": 250}]}}]}"
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: try! PBMFunctions.dictionaryFromJSONString(sdkORTB),
            impORTB: impORTB,
            globalORTB: nil
        )
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithImp_emptyExistingORTB() {
        let impORTB = "{\"banner\": {\"format\": [{\"w\": 300, \"h\": 250}]}}"
        let sdkORTB = "{}"
        let expectedORTB = "{\"imp\": [{\"banner\": {\"format\": [{\"w\": 300, \"h\": 250}]}}]}"
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: try! PBMFunctions.dictionaryFromJSONString(sdkORTB),
            impORTB: impORTB,
            globalORTB: nil
        )
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_WithImpInGlobal() {
        let globalORTB = """
        {
            "imp": [
                {
                    "id": "globalImp1",
                    "banner": { "w": 728, "h": 90 }
                }
            ]
        }
        """
        
        let sdkORTB: [String: Any] = [
            "imp": [
                ["id": "existingImp", "native": ["request": "placeholder"]]
            ]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        XCTAssertNotNil(result)
        
        let expectedORTB = """
        {
            "imp": [
                {
                    "id": "existingImp",
                    "native": { "request" : "placeholder" }
                },
                {
                    "id": "globalImp1",
                    "banner": { "w": 728, "h": 90 }
                }
            ]
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithImp_providedGlobalAndImpressionLevelImps() {
        let impORTB = "{\"banner\": {\"format\": [{\"w\": 300, \"h\": 250}]}}"
        
        let globalORTB = """
        {
            "imp": [
                {"banner": {"format": [{"w": 728, "h": 90}]},"id": "imp1"},
                {"id": "imp2", "video": {"mimes": ["video/mp4"]}}
            ]
        }
        """
        
        let sdkORTB = """
        {
            "imp": [
                {"banner": {"format": [{"w": 320, "h": 50}]}, "id": "existing_imp"}
            ],
            "device": {"ua": "Mozilla/5.0"}
        }
        """
        
        // Impression-level config should update existing imp property.
        // Global-level config should add more imps to imp property.
        let expectedORTB = """
        {
            "device": {"ua": "Mozilla/5.0"},
            "imp": [
                {"id": "existing_imp", "banner": {"format": [{"w": 320, "h": 50},{"w": 300, "h": 250}]}},
                {"id": "imp1", "banner": {"format": [{"w": 728, "h": 90}]}},
                {"id": "imp2", "video": {"mimes": ["video/mp4"]}},
            ]
        }
        """
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: try! PBMFunctions.dictionaryFromJSONString(sdkORTB),
            impORTB: impORTB,
            globalORTB: globalORTB
        )
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithImp_BothGlobalAndImpConfigProvided_WithEmptyExistingORTB() {
        let impORTB = """
        {
           "id": "imp1",
           "native": { "request": "placeholder" }
        }
        """
        
        let globalORTB = """
        {
           "imp": [{"id": "global_imp", "banner": {"format": [{"w": 320, "h": 50}]}}]
        }
        """
        
        let sdkORTB: [String: Any] = [:]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: impORTB,
            globalORTB: globalORTB
        )
        
        XCTAssertNotNil(result)
        
        let expectedORTB = """
        {
           "imp": [
               {
                   "id": "imp1",
                   "native": { "request": "placeholder" }
               },
               {
                   "id": "global_imp",
                   "banner": {"format": [{"w": 320, "h": 50}]},
               }
           ]
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_AppObject_NoConflicts() {
        let globalORTB = """
         {
            "app": {
                "storeurl": "https://example.com/app"
            }
         }
        """
        let sdkORTB: [String: Any] = [
            "app": [
                "name": "TestApp",
                "bundle": "com.example.testapp"
            ]
        ]
        
        let expectedORTB = """
        {
            "app": {
                "name": "TestApp",
                "bundle": "com.example.testapp",
                "storeurl": "https://example.com/app"
            }
        }
        """
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_AppObject_WithConflicts() {
        let globalORTB = """
        {
            "app": {
                "version": "2.0"
            }
        }
        """
        let sdkORTB: [String: Any] = [
            "app": [
                "name": "TestApp",
                "version": "1.0"
            ]
        ]
        
        let expectedORTB = """
        {
            "app": {
                "name": "TestApp",
                "version": "2.0"
            }
        }
        """
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_UserObject_NoConflicts() {
        let globalORTB = """
        {
            "user": {
                "id": "12345",
                "buyeruid": "buyer123"
            }
        }
        """
        let sdkORTB: [String: Any] = [
            "user": [
                "geo": [
                    "lat": 37,
                    "lon": -122
                ]
            ]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        let expectedORTB = """
        {
            "user": {
                "id": "12345",
                "buyeruid": "buyer123",
                "geo": {
                    "lat": 37,
                    "lon": -122
                }
            }
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_UserObject_WithConflicts() {
        let globalORTB = """
        {
            "user": {
                "id": "override123",
                "geo": {
                    "country": "CA"
                }
            }
        }
        """
        let sdkORTB: [String: Any] = [
            "user": [
                "id": "12345",
                "geo": [
                    "country": "US"
                ]
            ]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        let expectedORTB = """
        {
            "user": {
                "id": "override123",
                "geo": {
                    "country": "US"
                }
            }
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_UserObject_ProtectedFieldsNotCopied() {
        let globalORTB = """
        {
            "user": {
                "id": "12345",
                "ext": {
                    "consent": "someConsentString",
                    "otherField": "allowedValue"
                },
                "geo": {
                    "country": "US"
                }
            }
        }
        """
        let sdkORTB: [String: Any] = [
            "user": [
                "geo": [
                    "lat": 37,
                    "lon": -122
                ]
            ]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        let expectedORTB = """
        {
            "user": {
                "id": "12345",
                "geo": {
                    "lat": 37,
                    "lon": -122
                },
                "ext": {
                    "otherField": "allowedValue"
                }
            }
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_SourceObject_NoConflicts() {
        let globalORTB = """
        {
            "source": {
                "pchain": "pchainValue"
            }
        }
        """
        let sdkORTB: [String: Any] = [
            "source": [
                "ext": [
                    "tid": "transaction123"
                ]
            ]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        let expectedORTB = """
        {
            "source": {
                "ext": {
                    "tid": "transaction123"
                },
                "pchain": "pchainValue"
            }
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_SourceObject_WithConflicts() {
        let globalORTB = """
        {
            "source": {
                "tid": "globalTransaction",
                "ext": {
                    "sourceType": "reseller"
                }
            }
        }
        """
        let sdkORTB: [String: Any] = [
            "source": [
                "tid": "existingTransaction",
                "ext": [
                    "sourceType": "direct"
                ]
            ]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        let expectedORTB = """
        {
            "source": {
                "tid": "globalTransaction",
                "ext": {
                    "sourceType": "reseller"
                }
            }
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGLobal_ExtObject_NoConflicts() {
        let globalORTB = """
        {
            "ext": {
                "test": {
                    "new": "value"
                },
                "prebid": {
                    "storedrequest": {
                        "id": "stored-request-id-placeholder"
                    }
                }
            }
        }
        """
        
        let sdkORTB: [String: Any] = [
            "ext": [
                "prebid": [
                    "existingConfig": "existingValue"
                ]
            ]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        let expectedORTB = """
         {
             "ext": {
                 "prebid": {
                    "existingConfig": "existingValue",
                    "storedrequest": {
                        "id": "stored-request-id-placeholder"
                    }
                 },
                 "test": {
                    "new": "value"
                 }
             }
         }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_ExtObject_WithConflicts() {
        let globalORTB = """
        {
            "ext": {
                "prebid": {
                    "sharedField": "globalSharedValue",
                    "globalConfig": "globalValue"
                }
            }
        }
        """
        let sdkORTB: [String: Any] = [
            "ext": [
                "prebid": [
                    "sharedField": "existingSharedValue",
                    "existingConfig": "existingValue"
                ]
            ]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        let expectedORTB = """
        {
            "ext": {
                "prebid": {
                    "sharedField": "globalSharedValue",
                    "existingConfig": "existingValue",
                    "globalConfig": "globalValue"
                }
            }
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_DeviceObject_NoConflicts() {
        let globalORTB = """
        {
            "device": {
                "test": 1
            }
        }
        """
        
        let sdkORTB: [String: Any] = [
            "device": [
                "language": "en",
                "connectiontype": 2
            ]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        let expectedORTB = """
        {
            "device": {
                "language": "en",
                "connectiontype": 2,
                "test": 1
            }
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMergeORTBWithGlobal_DeviceObject_ProtectedFieldsNotCopied() {
        let globalORTB = """
        {
            "device": {
                "ifa": "protectedValue",
                "os": "Android",
                "pxratio": 3.0
            }
        }
        """
        let sdkORTB: [String: Any] = [
            "device": [
                "os": "iOS",
                "model": "iPhone"
            ]
        ]
        
        let result = ArbitraryORTBService.merge(
            sdkORTB: sdkORTB,
            impORTB: nil,
            globalORTB: globalORTB
        )
        
        let expectedORTB = """
        {
            "device": {
                "os": "iOS",
                "model": "iPhone"
            }
        }
        """
        
        XCTAssertEqual(
            result as NSDictionary,
            try? PBMFunctions.dictionaryFromJSONString(expectedORTB) as NSDictionary
        )
    }
    
    func testMerge_WithEmptyORTBs() {
        let result = ArbitraryORTBService.merge(
            sdkORTB: [:],
            impORTB: nil,
            globalORTB: nil
        )
        
        XCTAssertTrue(result.isEmpty)
    }
}
