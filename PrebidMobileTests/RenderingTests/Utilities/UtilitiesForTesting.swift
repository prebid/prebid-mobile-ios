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

import XCTest

@testable import PrebidMobile

typealias JsonDictionary = [String:Any]

@objc class UtilitiesForTesting : NSObject {
    
    //Gets the bundle for the Unit Test Target (We keep JSON files and other test resources there)
    class func testBundle() -> Bundle {
        return Bundle(for: UtilitiesForTesting.self)
    }
    
    class func loadFileAsDataFromBundle(_ fileName:String) -> Data? {
        let bundlePath = UtilitiesForTesting.testBundle().bundlePath
        var url = URL(fileURLWithPath: bundlePath)
        url.appendPathComponent(fileName)
        
        let ret = try? Data(contentsOf: url)
        return ret
    }
    
    class func loadFileAsStringFromBundle(_ fileName:String) -> String? {
        guard let data = loadFileAsDataFromBundle(fileName) else {
            return nil
        }
        
        let ret = String(data: data, encoding: String.Encoding.utf8)
        return ret
    }
    
    class func loadFileAsDictFromBundle(_ fileName:String) -> JsonDictionary? {
        guard let data = loadFileAsDataFromBundle(fileName) else {
            return nil
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) else {
            return nil
        }
        
        let ret = jsonObject as? JsonDictionary
        return ret
    }
    
    class func loadPlistAsDictFromBundle(_ fileName:String) -> [String: AnyObject]? {
        //load the plist as data in memory
        guard let plistData = loadFileAsDataFromBundle(fileName) else {
            return nil
        }
        
        //use the format of a property list (xml)
        var format = PropertyListSerialization.PropertyListFormat.xml
        //convert the plist data to a Swift Dictionary
        guard let  plistDict = try! PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &format) as? [String : AnyObject] else {
            return nil
        }
        
        return plistDict
    }
    
    class func createConnectionForMockedTest() -> PrebidServerConnection {
        let connection = PrebidServerConnection()
        connection.protocolClasses.append(MockServerURLProtocol.self)
        
        return connection
    }
    
    class func createEmptyTransaction() -> PBMTransaction {
        let connection = PrebidServerConnection()
        let adConfiguration = AdConfiguration()
        
        let transaction = PBMTransaction(serverConnection:connection,
                                         adConfiguration:adConfiguration,
                                         models:[])
        
        return transaction;
    }
    
    class func createHTMLCreative(with model: PBMCreativeModel) -> PBMAbstractCreative {
        return PBMHTMLCreative(creativeModel: model,
                               transaction:UtilitiesForTesting.createEmptyTransaction())
    }
    
    class func createHTMLCreative(withView: Bool = true) -> PBMAbstractCreative {
        let model = PBMCreativeModel(adConfiguration:AdConfiguration())
        model.html = "<html>test html</html>"
        
        let creative = UtilitiesForTesting.createHTMLCreative(with: model)
        let modalManager = PBMModalManager()
        creative.modalManager = modalManager
        
        if withView {
            let webView = PBMWebView()
            creative.view = webView
        }
        
        return creative
    }
    
    class func createHTMLCreative(withModel model: PBMCreativeModel, withView:Bool = true) -> PBMHTMLCreative {
        let creative = PBMHTMLCreative(creativeModel: model, transaction:UtilitiesForTesting.createEmptyTransaction())
        
        if withView {
            let webView = PBMWebView()
            creative.view = webView
        }
        
        return creative
    }
    
    class func createTransactionWithHTMLCreative(withView:Bool = false, isInterstitial: Bool = false) -> PBMTransaction {
        let connection = PrebidServerConnection()
        let adConfiguration = AdConfiguration()
        adConfiguration.winningBidAdFormat = .banner
        adConfiguration.isInterstitialAd = isInterstitial
        
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        model.html = "<html>test html</html>"
        model.revenue = "1234"
        let creative = UtilitiesForTesting.createHTMLCreative(withModel: model, withView: withView)
        
        let transaction = PBMTransaction(serverConnection:connection,
                                         adConfiguration:adConfiguration,
                                         models:[model])
        
        transaction.creatives.add(creative)
        
        return transaction;
    }
    
    class func createTransactionWithHTMLCreativeWithParams(
        connection: PrebidServerConnectionProtocol,
        configuration: AdConfiguration) -> PBMTransaction {
            let model = PBMCreativeModel(adConfiguration:configuration)
            
            model.html = "<html>test html</html>"
            model.revenue = "1234"
            
            let creative = PBMHTMLCreative(creativeModel: model, transaction:UtilitiesForTesting.createEmptyTransaction())
            
            let transaction = PBMTransaction(serverConnection:connection,
                                             adConfiguration:configuration,
                                             models:[model])
            
            transaction.creatives.add(creative)
            
            return transaction;
        }
    
    class func createDummyTransaction(for adConfiguration: AdConfiguration) -> PBMTransaction {
        let connection = getMockedServerConnection()
        let model = PBMCreativeModel(adConfiguration: adConfiguration)
        
        let transaction = PBMTransaction(serverConnection:connection,
                                         adConfiguration:adConfiguration,
                                         models:[model])
        
        let creative = PBMHTMLCreative(creativeModel: model, transaction: transaction)
        
        transaction.creatives.add(creative)
        
        return transaction;
        
    }
    
    //MARK: JSON Comparison
    
    /**
     Converts `expected` and `actual` to NSDictionaries rep and performs a comparison
     - parameters:
     - testClosure: Run code that will generate log messages here
     - completion: This will pass the log file as $0:String. You can check if it contains an expected log message.
     */
    class func compareJSON(expected:String, actual:String, file:StaticString = #file, line:UInt = #line) {
        
        do {
            let dictExpected = try PBMFunctions.dictionaryFromJSONString(expected)
            let nsDictExpected = NSDictionary(dictionary: dictExpected)
            
            let dictActual = try PBMFunctions.dictionaryFromJSONString(actual)
            let nsDictActual = NSDictionary(dictionary: dictActual)
            
            XCTAssertEqual(nsDictExpected, nsDictActual, file:file, line:line)
        } catch {
            XCTFail("error \(error)", file:file, line:line)
        }
    }
    
    class func compareRawResponse(acjFileName:String, adDetails:PBMAdDetails, file:StaticString = #file, line:UInt = #line) {
        
        guard let strExpected = UtilitiesForTesting.loadFileAsStringFromBundle(acjFileName) else {
            XCTFail("Could not open file \(acjFileName)", file:file, line:line)
            return
        }
        
        guard let strActual = adDetails.rawResponse else {
            XCTFail("No raw response", file:file, line:line)
            return
        }
        
        compareJSON(expected:strExpected, actual:strActual, file:file, line:line)
    }
    
    // MARK - Log
    @objc class func prepareLogFile() {
        Log.clearLogFile()
        Log.logToFile = true
    }
    
    @objc class func releaseLogFile() {
        Log.logToFile = false
        Log.clearLogFile()
    }
    
    class func checkLogContains(_ log: String, cleanFile: Bool = true, file:StaticString = #file, line:UInt = #line) {
        guard let log = Log.getLogFileAsString() else {
            XCTFail()
            return
        }
        XCTAssertTrue(log.contains(log), file: file, line: line)
        
        if cleanFile {
            releaseLogFile()
        }
    }
    
    /**
     Allows user to Run `testClosure` then review the log file with `completion`
     - parameters:
     - testClosure: Run code that will generate log messages here
     - checkLogFor: XCTAssert that the log will contain the following messages
     */
    class func executeTestClosure(_ testClosure:() -> Void, checkLogFor:[String], file:StaticString = #file, line:UInt = #line) {
        
        let log = UtilitiesForTesting.executeTestClosure(testClosure)
        
        //Run the completion closure and pass the log string back to let the caller verify the log contents.
        for str in checkLogFor {
            XCTAssert(log.contains(str), "Expected log to contain \(str)", file:file, line:line)
        }
    }
    
    /**
     Allows user to Run `testClosure` then review the log file with `completion`
     - parameters:
     - testClosure: Run code that will generate log messages here
     
     - returns: The log file as a String
     */
    class func executeTestClosure(_ testClosure:() -> Void, file:StaticString = #file, line:UInt = #line) -> String {
        
        Log.clearLogFile()
        
        //Turn on writing to the log file and defer turning it off.
        //This will keep writeToLog true until after getLogFileAsString (which is synchronous on the loggingQueue) is done.
        Log.logToFile = true
        defer {
            Log.clearLogFile()
        }
        
        testClosure()
        
        let log = Log.getLogFileAsString() ?? ""
        return log
    }
    
    @objc public class func resetTargeting(_ targeting: Targeting)  {
        
        targeting.userGender = .unknown
        targeting.userID = nil
        targeting.buyerUID = nil
        targeting.publisherName = nil
        targeting.storeURL = nil
        targeting.userCustomData = nil
        targeting.userExt = nil
        targeting.eids = nil
        targeting.location = nil
        targeting.locationPrecision = nil
        targeting.sourceapp = nil
        targeting.storeURL = nil
        targeting.domain = nil
        targeting.itunesID = nil
        targeting.omidPartnerName = nil
        targeting.omidPartnerVersion = nil
        
        targeting.parameterDictionary = [:]
        targeting.subjectToCOPPA = false
        targeting.subjectToGDPR = nil
        targeting.gdprConsentString = nil
        targeting.purposeConsents = nil
        targeting.sendSharedId = false
        
        targeting.clearAppExtData()
        targeting.clearAppKeywords()
        targeting.clearUserData()
        targeting.clearUserKeywords()
        targeting.clearYearOfBirth()
        targeting.clearAccessControlList()
        targeting.resetSharedId()
        
        UserDefaults.standard.removeObject(forKey: UserConsentDataManager.shared.IABTCF_ConsentString)
        UserDefaults.standard.removeObject(forKey: UserConsentDataManager.shared.IABTCF_SubjectToGDPR)
        UserDefaults.standard.removeObject(forKey: UserConsentDataManager.shared.IABTCF_PurposeConsents)
        UserDefaults.standard.removeObject(forKey: InternalUserConsentDataManager.IABUSPrivacy_StringKey)
        UserDefaults.standard.removeObject(forKey: InternalUserConsentDataManager.IABGPP_GppSID)
        UserDefaults.standard.removeObject(forKey: InternalUserConsentDataManager.IABGPP_HDR_GppString)
        
        checkInitialValues(targeting)
    }
    
    @objc public class func checkInitialValues(_ targeting: Targeting) {
        XCTAssertEqual(targeting.userGender, .unknown)
        XCTAssertNil(targeting.userID)
        XCTAssertNil(targeting.buyerUID)
        XCTAssertNil(targeting.publisherName)
        XCTAssertNil(targeting.storeURL)
        XCTAssertNil(targeting.userCustomData)
        XCTAssertNil(targeting.userExt)
        XCTAssertNil(targeting.eids)
        XCTAssertNil(targeting.location)
        XCTAssertNil(targeting.locationPrecision)
        XCTAssertNil(targeting.sourceapp)
        XCTAssertNil(targeting.storeURL)
        XCTAssertNil(targeting.domain)
        XCTAssertNil(targeting.itunesID)
        XCTAssertNil(targeting.omidPartnerName)
        XCTAssertNil(targeting.omidPartnerVersion)
        XCTAssert(targeting.parameterDictionary == [:])
        XCTAssertTrue(targeting.getAppKeywords().isEmpty)
        XCTAssertTrue(targeting.getAppExtData().isEmpty)
        XCTAssertTrue(targeting.getUserKeywords().isEmpty)
        XCTAssertTrue(targeting.userDataDictionary.isEmpty)
        XCTAssertTrue(targeting.accessControlList.isEmpty)
        XCTAssert(targeting.yearOfBirth == 0)
        XCTAssertFalse(targeting.sendSharedId)
        
        XCTAssertNil(UserDefaults.standard.object(forKey: UserConsentDataManager.shared.IABTCF_ConsentString))
        XCTAssertNil(UserDefaults.standard.object(forKey: UserConsentDataManager.shared.IABTCF_SubjectToGDPR))
        XCTAssertNil(UserDefaults.standard.object(forKey: UserConsentDataManager.shared.IABTCF_PurposeConsents))
        XCTAssertNil(UserDefaults.standard.object(forKey: InternalUserConsentDataManager.IABUSPrivacy_StringKey))
    }
    
    // Prepends "mraid:" and converts to a URL.
    class func getMRAIDURL(_ command: String) -> URL {
        guard let url = URL(string: "mraid:\(command)") else {
            // Not ideal, but maybe more helpful than bad access?
            XCTFail("Could not create MRAID URL with \"\(command)\"")
            return URL(fileURLWithPath: "")
        }
        return url
    }
}
