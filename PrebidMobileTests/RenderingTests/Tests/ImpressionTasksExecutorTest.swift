//
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

class ImpressionTasksExecutorTest: XCTestCase {
    
    var expectationCommandExecuted: XCTestExpectation?
    
    var readyToDisplayBlock: (() -> Void)?
    
    var log = ""
    
    override func tearDown() {
        self.log = ""
        super.tearDown()
    }
    
    func testImpessionTaskExecution() {
        let expectation = expectation(description: "test execute time")
        expectation.expectedFulfillmentCount = 3
        
        let task1 = ImpressionTask(task: { [weak self](completion) in
            guard let self = self else { return }
            print("startImpression is called 1")
            print("startImpression \(Date())")
            self.log += "startImpression is called 1\n"
            completion()
        }, delayInterval: 5)
        let task2 = ImpressionTask(task: { (completion) in
            print("endImpression is called 1")
            print("endImpression \(Date())")
            self.log += "endImpression is called 1\n"
            expectation.fulfill()
            completion()
        }, delayInterval: 0)
        ImpressionTasksExecutor.shared.add(tasks: [task1, task2])
        let task3 = ImpressionTask(task: { (completion) in
            print("startImpression is called 2")
            print("startImpression \(Date())")
            self.log += "startImpression is called 2\n"
            completion()
        }, delayInterval: 5)
        let task4 = ImpressionTask(task: { (completion) in
            print("endImpression is called 2")
            print("endImpression \(Date())")
            self.log += "endImpression is called 2\n"
            expectation.fulfill()
            completion()
        }, delayInterval: 0)
        ImpressionTasksExecutor.shared.add(tasks: [task3, task4])
        let task5 = ImpressionTask(task: { (completion) in
            print("startImpression is called 3")
            print("startImpression \(Date())")
            self.log += "startImpression is called 3\n"
            completion()
        }, delayInterval: 5)
        let task6 = ImpressionTask(task: { (completion) in
            print("endImpression is called 3")
            print("endImpression \(Date())")
            self.log += "endImpression is called 3\n"
            expectation.fulfill()
            completion()
        }, delayInterval: 0)
        ImpressionTasksExecutor.shared.add(tasks: [task5, task6])
        waitForExpectations(timeout: 30, handler: nil)
        
        XCTAssertTrue(log == "startImpression is called 1\nendImpression is called 1\nstartImpression is called 2\nendImpression is called 2\nstartImpression is called 3\nendImpression is called 3\n")
    }
}
