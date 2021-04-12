//
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@testable import OpenXApolloSDK
import XCTest

class OXMTransactionTests: XCTestCase {
    
    let connection = OXMServerConnection()
    let adConfiguration = OXMAdConfiguration()
    
    func testTransactionWithoutCreative() {
        
        let transaction = createTransactionWithHTMLModel()
        let details = transaction.getAdDetails()
        XCTAssertNil(details)

        let firstCreative = transaction.getFirstCreative()
        XCTAssertNil(firstCreative)
        
        let model = transaction.creativeModels.first!
        let creative = UtilitiesForTesting.createHTMLCreative(withModel: model, withView: true)
        let nextCreative = transaction.getCreativeAfter(creative)
        XCTAssertNil(nextCreative)

        let revenue = transaction.revenueForCreative(after: creative)
        XCTAssertNotNil(revenue)
        XCTAssertEqual(model.revenue, revenue)
    }
    
    func testTransactionWithCreative() {
        
        let transaction = createTransactionWithHTMLModel()
        let model = transaction.creativeModels.first!
        let creative = UtilitiesForTesting.createHTMLCreative(withModel: model, withView: true)
        transaction.creatives.add(creative)
        
        let details = transaction.getAdDetails()
        XCTAssertNil(details)
        
        let firstCreative = transaction.getFirstCreative()!
        XCTAssertNotNil(firstCreative)
        
        var nextCreative = transaction.getCreativeAfter(firstCreative)
        XCTAssertNil(nextCreative)
        
        transaction.creatives.add(UtilitiesForTesting.createHTMLCreative(withModel: model, withView: true))
        nextCreative = transaction.getCreativeAfter(firstCreative)
        XCTAssertNotNil(nextCreative)
        
        let revenue = transaction.revenueForCreative(after: creative)
        XCTAssertNotNil(revenue)
        XCTAssertEqual(model.revenue, revenue)
    }
    
    func testUpdateAdConfiguration() {
        
        let oxmServerConnection = OXMServerConnection()
        
        //Set up
        let adConfiguration = OXMAdConfiguration()

        adConfiguration.autoRefreshDelay = nil
        adConfiguration.autoRefreshMax = nil
        
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreativeWithParams(
            connection: oxmServerConnection,
            configuration: adConfiguration)
        
        XCTAssertEqual(transaction.adConfiguration.size, CGSize(width: 0, height: 0))

        let model = OXMCreativeModel(adConfiguration: OXMAdConfiguration())
        model.width = 42
        model.height = 42
        
        transaction.creativeModels.insert(model, at: 0)
        
        transaction.updateAdConfiguration()
        
        XCTAssertEqual(transaction.adConfiguration.size, CGSize(width: 42.0, height: 42.0))
    }
    
    // MARK: - Helper Methods
    
    func createTransactionWithHTMLModel() -> OXMTransaction {
        let model = OXMCreativeModel(adConfiguration:adConfiguration)
        model.html = "<html>test html</html>"
        model.revenue = "1234"
        
        let transaction = OXMTransaction(serverConnection:connection,
                                         adConfiguration:adConfiguration,
                                         models:[model])
        return transaction;
    }
}
