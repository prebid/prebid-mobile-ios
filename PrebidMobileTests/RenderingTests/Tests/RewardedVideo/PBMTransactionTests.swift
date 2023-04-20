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

class PBMTransactionTests: XCTestCase {
    
    let connection = PrebidServerConnection()
    let adConfiguration = AdConfiguration()
    
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
        
        let serverConnection = PrebidServerConnection()
        
        //Set up
        let adConfiguration = AdConfiguration()

        adConfiguration.autoRefreshDelay = nil
        adConfiguration.autoRefreshMax = nil
        
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreativeWithParams(
            connection: serverConnection,
            configuration: adConfiguration)
        
        XCTAssertEqual(transaction.adConfiguration.size, CGSize(width: 0, height: 0))

        let model = PBMCreativeModel(adConfiguration: AdConfiguration())
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
