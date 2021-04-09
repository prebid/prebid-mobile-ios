//
//  OXMTransactionsCacheTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class OXMTransactionsCacheTest: XCTestCase {
    
    // MARK: - Initialization
    
    var mockedCache: MockTransactionsCache!
    
    override func setUp() {
        super.setUp()
        mockedCache = MockTransactionsCache()
        mockedCache.clear()
    }
    
    override func tearDown() {
        super.tearDown()
        mockedCache.clear()
    }
    
    // MARK: - Tests
    
    func testCacheTransaction() {
        
        let cache = OXMTransactionsCache()
        
        let (adConfig1, transaction1) = adTestTransaction(to: cache)
        let (adConfig2, transaction2) = adTestTransaction(to: cache)
        let (adConfig3, transaction3) = adTestTransaction(to: cache)
        
        XCTAssertFalse(transaction1 === transaction2)
        XCTAssertFalse(transaction2 === transaction3)
        XCTAssertFalse(transaction1 === transaction3)
        
        XCTAssertEqual(cache.cache.count, 3)
        XCTAssertTrue(transaction1 === cache.extractTransaction(for: adConfig1))
        XCTAssertEqual(cache.cache.count, 2)
        XCTAssertTrue(transaction2 === cache.extractTransaction(for: adConfig2))
        XCTAssertEqual(cache.cache.count, 1)
        XCTAssertTrue(transaction3 === cache.extractTransaction(for: adConfig3))
        XCTAssertEqual(cache.cache.count, 0)
        
        cache.clear()
    }
    
    func testCacheExpirationDates() {
        
        let currentDate = Date()
        Thread.sleep(forTimeInterval: 1)
        
        let _ = adTestTransaction(to: mockedCache)
        Thread.sleep(forTimeInterval: 1)

        let _ = adTestTransaction(to: mockedCache)
        Thread.sleep(forTimeInterval: 1)

        let _ = adTestTransaction(to: mockedCache)
        Thread.sleep(forTimeInterval: 1)

        let dates = getTransactionsExpirationDates(from: mockedCache)
        XCTAssertEqual(dates.count, 3)
        
        dates.forEach { expirationDate in
            let diff = expirationDate.timeIntervalSince(currentDate)
            XCTAssertTrue(diff > (60 * 60))
        }
    }
    
    func testNextExpirationDate() {
        
        let cache = OXMTransactionsCache()

        let (adConfig1, _) = adTestTransaction(to: cache)
        Thread.sleep(forTimeInterval: 1)
        
        let (adConfig2, _) = adTestTransaction(to: cache)
        Thread.sleep(forTimeInterval: 1)
        
        let (adConfig3, _) = adTestTransaction(to: cache)
        Thread.sleep(forTimeInterval: 1)
        
        XCTAssertEqual(cache.nextExpirationDate(), getTransactionsExpirationDates(from: cache).sorted().first)
        
        cache.extractTransaction(for: adConfig1)
        XCTAssertEqual(cache.nextExpirationDate(), getTransactionsExpirationDates(from: cache).sorted().first)
        
        cache.extractTransaction(for: adConfig2)
        XCTAssertEqual(cache.nextExpirationDate(), getTransactionsExpirationDates(from: cache).sorted().first)
        
        cache.extractTransaction(for: adConfig3)
        XCTAssertEqual(cache.nextExpirationDate(), nil)
        
        cache.clear()
    }
    
    func testExpirationOneTransaction() {
        
        mockedCache.testExpirationPeriod = 3
        
        let expirationExpectaion = expectation(description: "expirationExpectaion")
        
        self.mockedCache.testExpirationClosure = {
            expirationExpectaion.fulfill()
        }
        
        let _ = adTestTransaction(to: mockedCache)
        XCTAssertEqual(mockedCache.cache.count, 1)

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(mockedCache.cache.count, 0)
    }
    
    func testExpirationPeriodsForSeveralTransaction() {
        
        // PREPARE TEST
        
        // Description:
        // This test checks the working of expiration algorithm.
        // Expected timeline:
        // Tx - the point of caching transaction with number x
        // Ex - the point of expiration of transaction with number x
        // - - time interval (1 sec)
        //
        //
        //  |----- 5sec -----|                          >
        //                   |-- 2sec --|               > Expiration timer periods (dynamically calculated according to the expiration "next" date)
        //                             |-2sec-|         >
        //                                   |-2sec-|   >
        // (T1)--(T2)--(T3)-(E1)-(T4)-(E2)--(E3)--(E4)  : TIMELINE (total: 11sec)
        //  |----- 5sec -----|                          >
        //        |------- 5sec -------|                > Hardcoded Expiration time for transaction
        //              |------- 5sec -------|          >
        //                         |----- 5sec -----|   >
        
        
        mockedCache.testExpirationPeriod = 5 // Injected for test purposes

        var expectedPeriods: [TimeInterval] = [5, 2, 2, 2]
        let totalExpirationDuration = expectedPeriods.reduce(0, +)
        var startDate = Date()
        
        let expirationExpectaion = expectation(description: "expirationExpectaion")
        expirationExpectaion.expectedFulfillmentCount = 4 // We expect 4 expirations for 4 transaction
        
        self.mockedCache.testExpirationClosure = {
            guard expectedPeriods.count > 0 else {
                XCTFail()
                return
            }
            
            let period : TimeInterval = TimeInterval(expectedPeriods.first!)
            let currentDate = Date()
            XCTAssertEqual(period, currentDate.timeIntervalSince(startDate), accuracy: 0.3)
            
            expectedPeriods.removeFirst()
            
            startDate = currentDate
            
            expirationExpectaion.fulfill()
        }
        
        // RUN TEST
        
        // TRANSACTION 1
        let _ = self.adTestTransaction(to: mockedCache)
        let dispatchTime = DispatchTime.now()
        
        // TRANSACTION 2
        DispatchQueue.main.asyncAfter(deadline: dispatchTime + 2) {
            let _ = self.adTestTransaction(to: self.mockedCache)
        }
        
        // TRANSACTION 3
        DispatchQueue.main.asyncAfter(deadline: dispatchTime + 4) {
            let _ = self.adTestTransaction(to: self.mockedCache)
        }
        
        // TRANSACTION 4
        DispatchQueue.main.asyncAfter(deadline: dispatchTime + 6) {
            let _ = self.adTestTransaction(to: self.mockedCache)
        }
        
        waitForExpectations(timeout: totalExpirationDuration + 1)

        XCTAssertEqual(mockedCache.cache.count, 0)
    }
    
    func testClearCache() {
        
        let _ = adTestTransaction(to: mockedCache)
        let _ = adTestTransaction(to: mockedCache)
        let _ = adTestTransaction(to: mockedCache)
        
        XCTAssertEqual(mockedCache.cache.count, 3)
        
        mockedCache.clear()
        
        XCTAssertEqual(mockedCache.cache.count, 0)
    }
    
    // MARK: - Helper Methods
    
    private func adTestTransaction(to cache: OXMTransactionsCache, file: StaticString = #file, line: UInt = #line) -> (OXMAdConfiguration, OXMTransaction) {
        let adConfiguration = OXMAdConfiguration()
        
        let transaction = UtilitiesForTesting.createDummyTransaction(for: adConfiguration)
        
        cache.add(transaction)
        
        return (adConfiguration, transaction)
    }
    
    private func getTransactionsTags(from cache: OXMTransactionsCache) -> [OXMTransactionTag] {
        return cache.cache.allKeys.map{ $0 as? OXMTransactionTag }.compactMap{ $0 }
    }
    
    private func getTransactionsExpirationDates(from cache: OXMTransactionsCache) -> [Date] {
        return getTransactionsTags(from: cache).map{ $0.expirationDate }.compactMap{ $0 }
    }
}
