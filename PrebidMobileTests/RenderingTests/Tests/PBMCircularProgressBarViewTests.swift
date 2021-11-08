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

class PBMCircularProgressBarViewTests: XCTestCase {
    
    func testInit() {
        var circularProgressBarView = PBMCircularProgressBarView()
        XCTAssertNotNil(circularProgressBarView)
        
        let viewRect = CGRect(x: 0, y: 0, width: 50, height: 50)
        circularProgressBarView = PBMCircularProgressBarView(frame: viewRect)
        XCTAssertNotNil(circularProgressBarView)
    }
    
    func testProperties() {
        let showValueString = true
        let value: CGFloat = 10
        let valueFontName = "Some str"
        let maxValue: CGFloat = 10.0
        let borderPadding: CGFloat = 10
        let valueFontSize: CGFloat = 10
        let fontColor = UIColor.red
        let progressRotationAngle: CGFloat = 10
        let progressAngle: CGFloat = 10
        let progressLineWidth: CGFloat = 10
        let progressLinePadding: CGFloat = 10
        let progressColor = UIColor.red
        let emptyLineWidth: CGFloat = 10
        let emptyLineColor = UIColor.red
        let emptyLineStrokeColor = UIColor.red
        let emptyCapType = 10
        let textOffset = CGPoint(x: 10, y: 10)
        let countdown = true
        let duration: CGFloat = 10
        
        let circularProgressBarView = PBMCircularProgressBarView()
        XCTAssertNotNil(circularProgressBarView)
        
        // Setters
        circularProgressBarView.showValueString = showValueString
        circularProgressBarView.value = value
        circularProgressBarView.valueFontName = valueFontName
        circularProgressBarView.maxValue = maxValue
        circularProgressBarView.borderPadding = borderPadding
        circularProgressBarView.valueFontSize = valueFontSize
        circularProgressBarView.fontColor = fontColor
        circularProgressBarView.progressRotationAngle = progressRotationAngle
        circularProgressBarView.progressAngle = progressAngle
        circularProgressBarView.progressLineWidth = progressLineWidth
        circularProgressBarView.progressLinePadding = progressLinePadding
        circularProgressBarView.progressColor = progressColor
        circularProgressBarView.emptyLineWidth = emptyLineWidth
        circularProgressBarView.emptyLineColor = emptyLineColor
        circularProgressBarView.emptyLineStrokeColor = emptyLineStrokeColor
        circularProgressBarView.emptyCapType = emptyCapType
        circularProgressBarView.textOffset = textOffset
        circularProgressBarView.countdown = countdown
        circularProgressBarView.duration = duration
        
        // Getters
        XCTAssertEqual(circularProgressBarView.showValueString, showValueString)
        XCTAssertEqual(circularProgressBarView.value, value)
        XCTAssertEqual(circularProgressBarView.valueFontName, valueFontName)
        XCTAssertEqual(circularProgressBarView.maxValue, maxValue)
        XCTAssertEqual(circularProgressBarView.borderPadding, borderPadding)
        XCTAssertEqual(circularProgressBarView.valueFontSize, valueFontSize)
        XCTAssertEqual(circularProgressBarView.fontColor, fontColor)
        XCTAssertEqual(circularProgressBarView.progressRotationAngle, progressRotationAngle)
        XCTAssertEqual(circularProgressBarView.progressAngle, progressAngle)
        XCTAssertEqual(circularProgressBarView.progressLineWidth, progressLineWidth)
        XCTAssertEqual(circularProgressBarView.progressLinePadding, progressLinePadding)
        XCTAssertEqual(circularProgressBarView.progressColor, progressColor)
        XCTAssertEqual(circularProgressBarView.emptyLineWidth, emptyLineWidth)
        XCTAssertEqual(circularProgressBarView.emptyLineColor, emptyLineColor)
        XCTAssertEqual(circularProgressBarView.emptyLineStrokeColor, emptyLineStrokeColor)
        XCTAssertEqual(circularProgressBarView.emptyCapType, emptyCapType)
        XCTAssertEqual(circularProgressBarView.textOffset, textOffset)
        XCTAssertEqual(circularProgressBarView.countdown, countdown)
        XCTAssertEqual(circularProgressBarView.duration, duration)
    }
    
    func testUpdateProgress() {
        let duration: CGFloat = 10
        let circularProgressBarView = PBMCircularProgressBarView()
        XCTAssertNotNil(circularProgressBarView)
        
        XCTAssertEqual(circularProgressBarView.value, 0)
        XCTAssertEqual(circularProgressBarView.duration, 0)
        XCTAssertEqual(circularProgressBarView.maxValue, 100)
        
        circularProgressBarView.duration = duration
        circularProgressBarView.updateProgress(1)
        XCTAssertEqual(circularProgressBarView.value, 1)
        XCTAssertEqual(circularProgressBarView.duration, duration)
        XCTAssertEqual(circularProgressBarView.maxValue, duration)
        
        circularProgressBarView.updateProgress(5)
        XCTAssertEqual(circularProgressBarView.value, 5)
        XCTAssertEqual(circularProgressBarView.duration, duration)
        XCTAssertEqual(circularProgressBarView.maxValue, duration)
    }
    
    func testDataObject() {
        let data = NSKeyedArchiver.archivedData(withRootObject: PBMCircularProgressBarView())
        XCTAssertNotNil(data)
        let object = NSKeyedUnarchiver.unarchiveObject(with: data)
        XCTAssert(object is PBMCircularProgressBarView)
    }
}
