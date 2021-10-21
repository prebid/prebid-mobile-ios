import XCTest

class TestUtilitiesForTesting: XCTestCase {

	//Walk the sample json files we need for running unit tests and expect them all to load as NSData
	func testLoadFuncs() {
		
        let sampleJSONFileNames = ["ACJBanner.json", "ACJInterstitial.json", "ACJNonChainingAdUnit.json", "ACJNonChainingAdUnit.json", "ACJSingleAd.json"]
        
		for jsonFileName in sampleJSONFileNames {
			XCTAssert(UtilitiesForTesting.loadFileAsDataFromBundle(jsonFileName) != nil, "Expected data for file: \(jsonFileName)")
            XCTAssert(UtilitiesForTesting.loadFileAsStringFromBundle(jsonFileName) != nil, "Expected data for file: \(jsonFileName)")
            XCTAssert(UtilitiesForTesting.loadFileAsDictFromBundle(jsonFileName) != nil, "Expected data for file: \(jsonFileName)")
		}
	}

}
