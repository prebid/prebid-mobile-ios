//
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//
import XCTest

@testable import PrebidMobileRendering

class PBMTransactionTests: XCTestCase {
    
    let connection = PBMServerConnection()
    let adConfiguration = PBMAdConfiguration()
    
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
        
        let pbmServerConnection = PBMServerConnection()
        
        //Set up
        let adConfiguration = PBMAdConfiguration()

        adConfiguration.autoRefreshDelay = nil
        adConfiguration.autoRefreshMax = nil
        
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreativeWithParams(
            connection: pbmServerConnection,
            configuration: adConfiguration)
        
        XCTAssertEqual(transaction.adConfiguration.size, CGSize(width: 0, height: 0))

        let model = PBMCreativeModel(adConfiguration: PBMAdConfiguration())
        model.width = 42
        model.height = 42
        
        transaction.creativeModels.insert(model, at: 0)
        
        transaction.updateAdConfiguration()
        
        XCTAssertEqual(transaction.adConfiguration.size, CGSize(width: 42.0, height: 42.0))
    }
    
    // MARK: - Helper Methods
    
    func createTransactionWithHTMLModel() -> PBMTransaction {
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        model.html = "<html>test html</html>"
        model.revenue = "1234"
        
        let transaction = PBMTransaction(serverConnection:connection,
                                         adConfiguration:adConfiguration,
                                         models:[model])
        return transaction;
    }
}
