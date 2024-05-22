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

extension PrebidMRAID3MethodsUITest {
    enum ExamplePageInfo {
        enum Mode: CaseIterable {
            case `default`
            case resized_small
            case resized_large
            case expanded
            
            var title: String? {
                switch self {
                case .default:
                    return nil
                case .resized_small:
                    return "[Resized/Small]"
                case .resized_large:
                    return "[Resized/Large]"
                case .expanded:
                    return "[Expanded]"
                }
            }
        }
        struct Button {
            let title: String
            let modes: [Mode]
        }
        enum Buttons {
            static let expand = Button(title: "Expand", modes: [.default, .resized_small, .resized_large, .expanded])
            static let close = Button(title: "Close", modes: [.resized_small, .resized_large, .expanded])
            
            enum Resize {
                static let banner = Button(title: "Resize", modes: [.default])
                static let toLarge = Button(title: "Resize(320)", modes: [.resized_small, .resized_large, .expanded])
                static let toSmall = Button(title: "Resize(250)", modes: [.resized_large, .expanded])
                
                static var allVariants: [Button] { return [banner, toLarge, toSmall]; }
            }
            
            static var all: [Button] { return [expand, close] + Resize.allVariants }
        }
    }
}

class PrebidMRAID3MethodsUITest: RepeatedUITestCase {

    private let title = "MRAID OX: Test Methods 3.0 (In-App)"
    private let loadingTimeout = 10.0
    private let timeout = 7.0
    
    private let unloadCommand = "Unload"
    
    private var mode: ExamplePageInfo.Mode = .default
    
    override func setUp() {
        super.setUp()
    }
    
    // Resize → Resize (large) → Resize (small) →Close
    func testResizeResizeClose() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            
            tap(ExamplePageInfo.Buttons.Resize.banner)
            setMode(.resized_small)
            tap(ExamplePageInfo.Buttons.Resize.toLarge)
            setMode(.resized_large)
            tap(ExamplePageInfo.Buttons.Resize.toSmall)
            setMode(.resized_small)
            tap(ExamplePageInfo.Buttons.close)
            setMode(.default)
        }
    }
    
    // Resize → Unload
    func testResizeUnload() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            
            tap(ExamplePageInfo.Buttons.Resize.banner)
            setMode(.resized_small)
            
            tapMRAIDCommand(command: unloadCommand)
            
            let link = app.staticTexts[ExamplePageInfo.Buttons.close.title]
            waitForNotExist(element: link)
        }
    }
    
    // Resize → Expand → Expand (no errors) →Close
    func testResizeExpandExpandClose() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            
            tap(ExamplePageInfo.Buttons.expand)
            setMode(.expanded)
            tap(ExamplePageInfo.Buttons.expand) // Should be completely ignored
            setMode(.expanded)
            tap(ExamplePageInfo.Buttons.close)
            setMode(.default)
        }
    }
    
    // Expand → Resize (small, error) → Resize (large, error) →Close
    func testExpandResizeClose() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            
            tap(ExamplePageInfo.Buttons.expand)
            setMode(.expanded)
            let errorTxt = "message = \"MRAID cannot resize from state: expanded\", action = \"resize\""
            let errorMsg = app.staticTexts.matching(NSPredicate { obj, dic in
                ((obj as? XCUIElementAttributes)?.value as? String) == errorTxt
            })
            XCTAssertEqual(errorMsg.count, 0)
            tap(ExamplePageInfo.Buttons.Resize.toSmall) // Should report error
            setMode(.expanded)
            XCTAssertEqual(errorMsg.count, 1)
            tap(ExamplePageInfo.Buttons.Resize.toLarge) // Should report error
            setMode(.expanded)
            XCTAssertEqual(errorMsg.count, 2)
            tap(ExamplePageInfo.Buttons.close)
            setMode(.default)
        }
    }
    
    //MARK: - Private methods
    private func openAndWaitAd() {
        navigateToExamplesSection()
        navigateToExample(title)
        
        let adReceivedButton = app.buttons["adViewDidReceiveAd called"]
        let adFailedToLoadButton = app.buttons["adViewDidFailToLoadAd called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: loadingTimeout)
        
        mode = .default
        setMode(.default)
    }
    
    private func setMode(_ mode: ExamplePageInfo.Mode) {
        let oldMode = self.mode
        self.mode = mode
        if let title = mode.title {
            let link = app.staticTexts[title]
            waitForExists(element: link, waitSeconds: timeout)
        } else if let title = oldMode.title {
            let link = app.staticTexts[title]
            waitForNotExist(element: link, waitSeconds: timeout)
        } else {
            XCTAssertEqual(mode, oldMode)
        }
        for button in ExamplePageInfo.Buttons.all {
            let link = app.staticTexts[button.title]
            let linkExists = link.exists
            let linkShouldExist = button.modes.contains(mode)
            XCTAssertEqual(linkExists, linkShouldExist,
                           "'\(button.title)'.exists = \(linkExists), expected = \(linkShouldExist); mode = \(mode), previous = \(oldMode)")
        }
    }
    
    private func tap(_ button: ExamplePageInfo.Button) {
        let link = app.staticTexts[button.title]
        waitForHittable(element: link)
        link.tap()
    }
    
    func tapMRAIDCommand(command: String) {
        let link = app.staticTexts[command]
        waitForHittable(element: link, waitSeconds: 10)
        link.tap()
    }

}
