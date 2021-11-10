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

class PBMCircularProgressBarLayerTests: XCTestCase {
    
    func testNeedsDisplayForKey() {
        XCTAssertTrue(PBMCircularProgressBarLayer.needsDisplay(forKey: "value"))
        XCTAssertFalse(PBMCircularProgressBarLayer.needsDisplay(forKey: "nonNeedsDisplay"))
    }
    
    func testProperties() {
        let circularProgressBarView = PBMCircularProgressBarView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        XCTAssertNotNil(circularProgressBarView)
        
        guard let circularProgressBarLayer = circularProgressBarView.layer as? PBMCircularProgressBarLayer else {
            XCTFail()
            return
        }
        
        let showValueString = true
        let value: CGFloat = 10
        let valueFontName = "Some str"
        let maxValue: CGFloat = 10.0
        let valueFontSize: CGFloat = 10
        let fontColor = UIColor.red
        let progressRotationAngle: CGFloat = 10
        let progressAngle: CGFloat = 10
        let progressLineWidth: CGFloat = 10
        let progressLinePadding: CGFloat = 10
        let progressColor = UIColor.red
        let emptyLineWidth: CGFloat = 10
        let emptyLineColor = UIColor.red
        let countdown = true
        
        //Test that properties are passed correctly
        
        // Set properties
        circularProgressBarView.showValueString = showValueString
        circularProgressBarView.value = value
        circularProgressBarView.valueFontName = valueFontName
        circularProgressBarView.maxValue = maxValue
        circularProgressBarView.valueFontSize = valueFontSize
        circularProgressBarView.fontColor = fontColor
        circularProgressBarView.progressRotationAngle = progressRotationAngle
        circularProgressBarView.progressAngle = progressAngle
        circularProgressBarView.progressLineWidth = progressLineWidth
        circularProgressBarView.progressLinePadding = progressLinePadding
        circularProgressBarView.progressColor = progressColor
        circularProgressBarView.emptyLineWidth = emptyLineWidth
        circularProgressBarView.emptyLineColor = emptyLineColor
        circularProgressBarView.countdown = countdown
        
        //and get its from the underlying layer
        XCTAssertEqual(circularProgressBarLayer.showValueString, showValueString)
        XCTAssertEqual(circularProgressBarLayer.value, value)
        XCTAssertEqual(circularProgressBarLayer.valueFontName, valueFontName)
        XCTAssertEqual(circularProgressBarLayer.maxValue, maxValue)
        
        XCTAssertEqual(circularProgressBarLayer.valueFontSize, valueFontSize)
        XCTAssertEqual(circularProgressBarLayer.fontColor, fontColor)
        XCTAssertEqual(circularProgressBarLayer.progressRotationAngle, progressRotationAngle)
        XCTAssertEqual(circularProgressBarLayer.progressAngle, progressAngle)
        XCTAssertEqual(circularProgressBarLayer.progressLineWidth, progressLineWidth)
        XCTAssertEqual(circularProgressBarLayer.progressLinePadding, progressLinePadding)
        XCTAssertEqual(circularProgressBarLayer.progressColor, progressColor)
        XCTAssertEqual(circularProgressBarLayer.emptyLineWidth, emptyLineWidth)
        XCTAssertEqual(circularProgressBarLayer.emptyLineColor, emptyLineColor)
        XCTAssertEqual(circularProgressBarLayer.countdown, countdown)
    }
    
    func testUpdateProgress() {
        
        let viewRect = CGRect(x: 0, y: 0, width: 50, height: 50)
        let circularProgressBarView = PBMCircularProgressBarView(frame: viewRect)
        XCTAssertNotNil(circularProgressBarView)
        
        guard let circularProgressBarLayer = circularProgressBarView.layer as? PBMCircularProgressBarLayer else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(circularProgressBarView.value, 0)
        XCTAssertEqual(circularProgressBarLayer.value, 0)
        
        circularProgressBarView.duration = 10
        XCTAssertEqual(circularProgressBarView.duration, 10)
        
        circularProgressBarView.updateProgress(1)
        let context = makeContext(rect: viewRect)
        circularProgressBarLayer.draw(in: context)
        
        XCTAssertEqual(circularProgressBarView.value, 1)
        XCTAssertEqual(circularProgressBarLayer.value, 1)
        
        circularProgressBarView.updateProgress(2)
        circularProgressBarLayer.draw(in: context)
        
        XCTAssertEqual(circularProgressBarView.duration, 10)
        XCTAssertEqual(circularProgressBarView.value, 2)
        XCTAssertEqual(circularProgressBarLayer.value, 2)
    }
    
    func makeContext(rect: CGRect) -> CGContext {
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(UInt(rect.size.width)), height: Int(UInt(rect.size.height)), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        return context!
    }
}
