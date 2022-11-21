/*   Copyright 2018-2019 Prebid.org, Inc.
 
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

class StorageUtilsTests: XCTestCase {
    
    func testPB_ExternalUserIdsKey() {
        XCTAssertEqual("kPBExternalUserIds", StorageUtils.PB_ExternalUserIdsKey)
    }
    
    //MARK: - External UserIds
    func testPbExternalUserIds() {
        //given
        var externalUserIdArray = [ExternalUserId]()
        externalUserIdArray.append(ExternalUserId(source: "adserver.org", identifier: "111111111111", ext: ["rtiPartner" : "TDID"]))
        externalUserIdArray.append(ExternalUserId(source: "netid.de", identifier: "999888777"))
        externalUserIdArray.append(ExternalUserId(source: "criteo.com", identifier: "_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N"))
        externalUserIdArray.append(ExternalUserId(source: "liveramp.com", identifier: "AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg"))
        externalUserIdArray.append(ExternalUserId(source: "sharedid.org", identifier: "111111111111", atype: 1, ext: ["third" : "01ERJWE5FS4RAZKG6SKQ3ZYSKV"]))
        StorageUtils.setExternalUserIds(value: externalUserIdArray)
        defer {
            StorageUtils.setExternalUserIds(value: nil)
        }
        
        //when
        let externalUserIds = StorageUtils.getExternalUserIds()!
        
        //then
        XCTAssertEqual(5, externalUserIds.count)
        
        let adServerDic = externalUserIds[0]
        XCTAssertEqual("adserver.org", adServerDic.source)
        XCTAssertEqual("111111111111", adServerDic.identifier)
        XCTAssertEqual(["rtiPartner" : "TDID"], adServerDic.ext as! [String : String])
        
        let netIdDic = externalUserIds[1]
        XCTAssertEqual("netid.de", netIdDic.source)
        XCTAssertEqual("999888777", netIdDic.identifier)
        
        let criteoDic = externalUserIds[2]
        XCTAssertEqual("criteo.com", criteoDic.source)
        XCTAssertEqual("_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N", criteoDic.identifier)
        
        let liverampDic = externalUserIds[3]
        XCTAssertEqual("liveramp.com", liverampDic.source)
        XCTAssertEqual("AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg", liverampDic.identifier)
        
        let sharedIdDic = externalUserIds[4]
        XCTAssertEqual("sharedid.org", sharedIdDic.source)
        XCTAssertEqual("111111111111", sharedIdDic.identifier)
        XCTAssertEqual(1, sharedIdDic.atype)
        XCTAssertEqual(["third" : "01ERJWE5FS4RAZKG6SKQ3ZYSKV"], sharedIdDic.ext as! [String : String])
        
    }
    
}
