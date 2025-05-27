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

import Foundation

import XCTest

protocol Failable: ObjcFailable {
    func failWithMessage(_ message: String, file: String, line: UInt, nothrow: Bool)
}

extension Failable {
    func failWithMessage(_ message: String, file: String, line: UInt) {
        failWithMessage(message, file: file, line: line, nothrow: false)
    }
}

extension XCTestCase {
    
    // MARK: - Helper methods (wait)

    func waitForEnabled(element: XCUIElement, failElement: XCUIElement? = nil, waitSeconds: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) {
        let enabledPredicate = NSPredicate(format: "enabled == true")
        var error: String = "Failed to find enabled element \(element) after \(waitSeconds) seconds"
        if let failElement = failElement {
            error += " or element \(failElement) became enabled earlier."
        } else {
            error += "."
        }
        waitFor(element: element, predicate: enabledPredicate, failElement: failElement, failPredicate: enabledPredicate, message: error, waitSeconds: waitSeconds, file: file, line: line)
    }
    
    func waitForHittable(element: XCUIElement, waitSeconds: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "hittable == true")
        let error = "Failed to find \(element) after \(waitSeconds) seconds."
        waitFor(element: element, predicate: existsPredicate, message: error, waitSeconds: waitSeconds, file: file, line: line)
    }
    
    func waitForNotHittable(element: XCUIElement, waitSeconds: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) {
        let hittablePredicate = NSPredicate(format: "hittable == false")
        let error = "Failed to find \(element) after \(waitSeconds) seconds."
        waitFor(element: element, predicate: hittablePredicate, message: error, waitSeconds: waitSeconds, file: file, line: line)

    }
    
    func waitForExists(element: XCUIElement, waitSeconds: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        let error = "Failed to find \(element) after \(waitSeconds) seconds."
        waitFor(element: element, predicate: existsPredicate, message: error, waitSeconds: waitSeconds, file: file, line: line)
    }
    
    func waitForNotExist(element: XCUIElement, waitSeconds: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) {
        let predicate = NSPredicate(format: "exists != true")
        let error = "Element \(element) failed to be hidden after \(waitSeconds) seconds."
        waitFor(element: element, predicate: predicate, message: error, waitSeconds: waitSeconds, file: file, line: line)
    }
    
    func waitFor(element: XCUIElement, predicate: NSPredicate, message: String, waitSeconds: TimeInterval, file: StaticString, line: UInt) {
        waitFor(element: element, predicate: predicate, failElement: nil, failPredicate: nil, message: message, waitSeconds: waitSeconds, file: file, line: line)
    }
    
    private func waitFor(element: XCUIElement, predicate: NSPredicate, failElement: XCUIElement?, failPredicate: NSPredicate?, message: String, waitSeconds: TimeInterval, file: StaticString, line: UInt) {
        
        if let failElement = failElement, let failPredicate = failPredicate {
            let finishPredicate = NSPredicate { [weak self] (obj, bindings) -> Bool in
                guard let targets = obj as? [XCUIElement], targets.count == 2 else {
                    return false
                }
                let positiveOutcome = predicate.evaluate(with: targets[0])
                let negativeOutcome = failPredicate.evaluate(with: targets[1])
                if (negativeOutcome) {
                    self?.failHelper(message: "\(message) [early fail detection triggerred]", file: file, line: line, nothrow: true)
                }
                return positiveOutcome || negativeOutcome
            }
            let finishArgs = [element, failElement]
            expectation(for: finishPredicate, evaluatedWith: finishArgs, handler: nil)
        } else {
            expectation(for: predicate, evaluatedWith: element, handler: nil)
        }
    
        waitForExpectations(timeout: waitSeconds) { [weak self] (error) -> Void in
            if let error = error {
                self?.failHelper(message: "\(message) [error: \(error.localizedDescription)]", file: file, line: line, nothrow: true)
            }
        }
        
        guard predicate.evaluate(with: element) else {
            failHelper(message: "\(message) [predicate returned false]", file: file, line: line)
            return
        }
        
        if let failElement = failElement, let failPredicate = failPredicate {
            guard failPredicate.evaluate(with: failElement) == false else {
                failHelper(message: "\(message) [failPredicate returned true]", file: file, line: line)
                return
            }
        }
    }
    
    // MARK: - Helper methods (navigation)
    
    fileprivate func navigateToExample(app: XCUIApplication, title: String, file: StaticString = #file, line: UInt = #line) {
        app.searchFields.element.tap()
        app.searchFields.element.typeText(title)
        
        let listItem = app.tables.staticTexts[title]
        waitForExists(element: listItem, waitSeconds: 5, file: file, line: line)
        listItem.tap()
        
        let navBar = app.navigationBars[title]
        waitForExists(element: navBar, waitSeconds: 5, file: file, line: line)
    }

    fileprivate func pickSegment(app: XCUIApplication, segmentedIndex: Int, segment: String?, file: StaticString = #file, line: UInt = #line) {
        app.segmentedControls.allElementsBoundByIndex[segmentedIndex].buttons[segment ?? "All"].tap()
    }
    
    fileprivate func navigateToSection(app: XCUIApplication, title: String, file: StaticString = #file, line: UInt = #line) {
        let adapter = app.tabBars.buttons[title]
        waitForExists(element: adapter, waitSeconds: 5)
        adapter.tap()
    }
    
    // MARK: - Helper Methods (app management)
    
    class AppLifebox {
        var app: XCUIApplication!
        private var interruptionMonitor: NSObjectProtocol?
        private var removeMonitorClosure: (NSObjectProtocol) -> ()
        
        init(addMonitorClosure: (String, @escaping (XCUIElement) -> Bool) -> NSObjectProtocol?, removeMonitorClosure: @escaping (NSObjectProtocol) -> ()) {
            app = XCUIApplication()
    
            
            app.launchArguments.append("-keyUITests")
            
            app.launch()
            interruptionMonitor = addMonitorClosure("System Dialog") {
                (alert) -> Bool in
                alert.buttons["Don’t Allow"].tap()
                return true
            }
            app.navigationBars.firstMatch.tap()
            self.removeMonitorClosure = removeMonitorClosure
        }
        
        deinit {
            if let monitor = interruptionMonitor {
                interruptionMonitor = nil
                removeMonitorClosure(monitor)
            }
            if app.state != .notRunning {
                app.terminate()
            }
        }
    }
    
    func constructApp() -> AppLifebox {
        return AppLifebox( addMonitorClosure: self.addUIInterruptionMonitor, removeMonitorClosure: self.removeUIInterruptionMonitor)
    }
    
    // MARK: - Private Helpers (failing)
    
    private func failHelper(message: String, file: StaticString, line: UInt, nothrow: Bool = false) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        add(attachment)
        if let failable = self as? Failable {
            failable.failWithMessage(message, file: "\(file)", line: line, nothrow: nothrow)
        } else {
            XCTFail(message, file: file, line: line)
        }
    }
}

extension BaseUITestCase {
    enum Tag: String, CaseIterable {
        // Note: order defines search priority during the detection
        case native = "Native"
        case mraid = "MRAID"
        case video = "Video"
        case interstitial = "Interstitial"
        case banner = "Banner"
    }
    enum AdServer: String, CaseIterable {
        // Note: order defines search priority during the detection
        case inapp = "In-App"
        case gam    = "GAM"
    }
    private func detect<T: RawRepresentable & CaseIterable>(from exampleTitle: String) -> T? where T.RawValue == String {
        if let rawVal = T
            .allCases
            .map({ $0.rawValue })
            .filter({ exampleTitle.contains($0.replacingOccurrences(of: " ", with: "")) })
            .first
        {
            return T.init(rawValue: rawVal)
        } else {
            return nil
        }
    }
    
    func navigateToExample(_ title: String, file: StaticString = #file, line: UInt = #line) {
        navigateToExample(app: app, title: title, file: file, line: line)
    }
    
    func applyFilter(tag: Tag?, file: StaticString = #file, line: UInt = #line) {
        pickSegment(app: app, segmentedIndex: 0, segment: tag?.rawValue, file: file, line: line)
    }
    func applyFilter(adServer: AdServer?, file: StaticString = #file, line: UInt = #line) {
        pickSegment(app: app, segmentedIndex: 1, segment: adServer?.rawValue, file: file, line: line)
    }
    
    func navigateToExamplesSection(file: StaticString = #file, line: UInt = #line) {
        navigateToSection(app: app, title: "Examples", file: file, line: line)
    }
}
