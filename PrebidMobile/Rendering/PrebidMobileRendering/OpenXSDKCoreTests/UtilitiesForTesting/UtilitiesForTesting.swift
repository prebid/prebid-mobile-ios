import XCTest

@testable import PrebidMobileRendering

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
    
    class func createConnectionForMockedTest() -> OXMServerConnection {
        let connection = OXMServerConnection()
        connection.protocolClasses.add(MockServerURLProtocol.self)
        
        return connection
    }
    
    class func createEmptyTransaction() -> OXMTransaction {
        let connection = OXMServerConnection()
        let adConfiguration = OXMAdConfiguration()
        
        let transaction = OXMTransaction(serverConnection:connection,
                                         adConfiguration:adConfiguration,
                                         models:[])
        
        return transaction;
    }
    
    class func createHTMLCreative(with model: OXMCreativeModel) -> OXMAbstractCreative {
        return OXMHTMLCreative(creativeModel: model,
                               transaction:UtilitiesForTesting.createEmptyTransaction())
    }

    class func createHTMLCreative(withView: Bool = true) -> OXMAbstractCreative {
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        model.html = "<html>test html</html>"
        
        let creative = UtilitiesForTesting.createHTMLCreative(with: model)
        let modalManager = OXMModalManager()
        creative.modalManager = modalManager

        if withView {
            let webView = OXMWebView()
            creative.view = webView
        }
        
        return creative
    }

    class func createHTMLCreative(withModel model: OXMCreativeModel, withView:Bool = true) -> OXMHTMLCreative {
        let creative = OXMHTMLCreative(creativeModel: model, transaction:UtilitiesForTesting.createEmptyTransaction())
        
        if withView {
            let webView = OXMWebView()
            creative.view = webView
        }
        
        return creative
    }

    class func createTransactionWithHTMLCreative(withView:Bool = false) -> OXMTransaction {
        let connection = OXMServerConnection()
        let adConfiguration = OXMAdConfiguration()
        
        let model = OXMCreativeModel(adConfiguration:adConfiguration)
        model.html = "<html>test html</html>"
        model.revenue = "1234"
        let creative = UtilitiesForTesting.createHTMLCreative(withModel: model, withView: withView)

        let transaction = OXMTransaction(serverConnection:connection,
                                          adConfiguration:adConfiguration,
                                                   models:[model])
        
        transaction.creatives.add(creative)
        
        return transaction;
    }
    
    class func createTransactionWithHTMLCreativeWithParams(
                                        connection: OXMServerConnectionProtocol,
                                        configuration: OXMAdConfiguration) -> OXMTransaction {
        let model = OXMCreativeModel(adConfiguration:configuration)
        
        model.html = "<html>test html</html>"
        model.revenue = "1234"
        
        let creative = OXMHTMLCreative(creativeModel: model, transaction:UtilitiesForTesting.createEmptyTransaction())
        
        let transaction = OXMTransaction(serverConnection:connection,
                                          adConfiguration:configuration,
                                                   models:[model])
        
        transaction.creatives.add(creative)
        
        return transaction;
    }
    
    class func createDummyTransaction(for adConfiguration: OXMAdConfiguration) -> OXMTransaction {
        let connection = getMockedServerConnection()
        let model = OXMCreativeModel(adConfiguration: adConfiguration)
        
        let transaction = OXMTransaction(serverConnection:connection,
                                         adConfiguration:adConfiguration,
                                         models:[model])
        
        let creative = OXMHTMLCreative(creativeModel: model, transaction: transaction)

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
            let dictExpected = try OXMFunctions.dictionaryFromJSONString(expected)
            let nsDictExpected = NSDictionary(dictionary: dictExpected)
            
            let dictActual = try OXMFunctions.dictionaryFromJSONString(actual)
            let nsDictActual = NSDictionary(dictionary: dictActual)
            
            XCTAssertEqual(nsDictExpected, nsDictActual, file:file, line:line)
        } catch {
            XCTFail("error \(error)", file:file, line:line)
        }
    }
    
    class func compareRawResponse(acjFileName:String, adDetails:OXMAdDetails, file:StaticString = #file, line:UInt = #line) {

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
        OXMLog.singleton.clearLogFile()
        OXMLog.singleton.logToFile = true;
    }
    
    @objc class func releaseLogFile() {
        OXMLog.singleton.logToFile = false;
        OXMLog.singleton.clearLogFile()
    }
    
    class func checkLogContains(_ log: String, cleanFile: Bool = true, file:StaticString = #file, line:UInt = #line) {
        let log = OXMLog.singleton.getLogFileAsString()
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
    class func executeTestClosure(_ testClosure:() -> Void, checkLogFor:[String], logger: OXMLog = OXMLog.singleton, file:StaticString = #file, line:UInt = #line) {

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
    class func executeTestClosure(_ testClosure:() -> Void, logger: OXMLog = OXMLog.singleton, file:StaticString = #file, line:UInt = #line) -> String {
        
        logger.clearLogFile()
        
        //Turn on writing to the log file and defer turning it off.
        //This will keep writeToLog true until after getLogFileAsString (which is synchronous on the loggingQueue) is done.
        logger.logToFile = true
        defer {
            logger.clearLogFile()
        }
        
        testClosure()
        
        let log = logger.getLogFileAsString()
        return log
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

