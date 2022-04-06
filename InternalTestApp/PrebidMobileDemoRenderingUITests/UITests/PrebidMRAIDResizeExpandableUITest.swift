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

extension PrebidMRAIDResizeExpandableUITest {
    enum Ad {
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

class PrebidMRAIDResizeExpandableUITest: RepeatedUITestCase {

    private let loadingTimeout = 8.0
    private let timeout = 7.0
    private var mode: Ad.Mode = .default
    
    private let title = "MRAID OX: Resize (Expandable) (In-App)"
    
    override func setUp() {
        super.setUp()
    }
    
    func testResizeClose() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            
            tap(Ad.Buttons.Resize.banner)
            setMode(.resized_small)
            tap(Ad.Buttons.close)
            setMode(.default)
        }
    }
    
    func testResizeToLargeClose() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            
            tap(Ad.Buttons.Resize.banner)
            setMode(.resized_small)
            tap(Ad.Buttons.Resize.toLarge)
            setMode(.resized_large)
            tap(Ad.Buttons.close)
            setMode(.default)
        }
    }
    
    func testResizeToLargeToSmallClose() {
        repeatTesting(times: 7) {
        openAndWaitAd()
            tap(Ad.Buttons.Resize.banner)
            setMode(.resized_small)
            tap(Ad.Buttons.Resize.toLarge)
            setMode(.resized_large)
            tap(Ad.Buttons.Resize.toSmall)
            setMode(.resized_small)
            tap(Ad.Buttons.close)
            setMode(.default)
        }
    }
    
    func testExpandClose() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            tap(Ad.Buttons.expand)
            setMode(.expanded)
            tap(Ad.Buttons.close)
            setMode(.default)
        }
    }
    
    func testResizeExpandClose() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            tap(Ad.Buttons.Resize.banner)
            setMode(.resized_small)
            tap(Ad.Buttons.expand)
            setMode(.expanded)
            tap(Ad.Buttons.close)
            setMode(.default)
        }
    }
    
    func testResizeToLargeExpandClose() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            tap(Ad.Buttons.Resize.banner)
            setMode(.resized_small)
            tap(Ad.Buttons.Resize.toLarge)
            setMode(.resized_large)
            tap(Ad.Buttons.expand)
            setMode(.expanded)
            tap(Ad.Buttons.close)
            setMode(.default)
        }
    }
    
    func testResizeExpandExpandClose() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            tap(Ad.Buttons.expand)
            setMode(.expanded)
            tap(Ad.Buttons.expand) // Should be completely ignored
            setMode(.expanded)
            tap(Ad.Buttons.close)
            setMode(.default)
        }
    }
    
    func testExpandResizeClose() {
        repeatTesting(times: 7) {
            openAndWaitAd()
            tap(Ad.Buttons.expand)
            setMode(.expanded)
            let errorTxt = "message = \"MRAID cannot resize from state: expanded\", action = \"resize\""
            let errorMsg = app.staticTexts.matching(NSPredicate { obj, dic in
                ((obj as? XCUIElementAttributes)?.value as? String) == errorTxt
            })
            XCTAssertEqual(errorMsg.count, 0)
            tap(Ad.Buttons.Resize.toSmall) // Should report error
            setMode(.expanded)
            XCTAssertEqual(errorMsg.count, 1)
            tap(Ad.Buttons.Resize.toLarge) // Should report error
            setMode(.expanded)
            XCTAssertEqual(errorMsg.count, 2)
            tap(Ad.Buttons.close)
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
    
    func setMode(_ mode: Ad.Mode) {
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
        for button in Ad.Buttons.all {
            let link = app.staticTexts[button.title]
            let linkExists = link.exists
            let linkShouldExist = button.modes.contains(mode)
            XCTAssertEqual(linkExists, linkShouldExist,
                           "'\(button.title)'.exists = \(linkExists), expected = \(linkShouldExist); mode = \(mode), previous = \(oldMode)")
        }
        if oldMode.title == nil, mode.title != nil {
            waitForEnabled(element: app.buttons["adViewWillPresentScreen called"], waitSeconds: timeout)
        } else if oldMode.title != nil, mode.title == nil {
            waitForEnabled(element: app.buttons["adViewDidDismissScreen called"], waitSeconds: timeout)
        }
    }
    
    func tap(_ button: Ad.Button, file: StaticString = #file, line: UInt = #line) {
        let link = app.staticTexts[button.title]
        waitForHittable(element: link)
        link.tap()
    }

}
