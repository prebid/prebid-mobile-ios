/*   Copyright 2018-2021 Prebid.org, Inc.

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

import UIKit

@objc(PBMCircularProgressBarView)
public class CircularProgressBarView: UIView {

    // MARK: - Public properties (forwarded to layer)

    @objc public var showValueString: Bool {
        get { progressLayer.showValueString }
        set { progressLayer.showValueString = newValue; layer.setNeedsDisplay() }
    }

    @objc public var value: CGFloat {
        get { progressLayer.value }
        set {
            progressLayer.value = newValue
            accessibilityValue = String(format: "%.0f", newValue)
            if newValue == 0 { layer.setNeedsDisplay() }
        }
    }

    @objc public var valueFontName: String {
        get { progressLayer.valueFontName }
        set { progressLayer.valueFontName = newValue }
    }

    @objc public var maxValue: CGFloat {
        get { progressLayer.maxValue }
        set { progressLayer.maxValue = newValue; if newValue == 0 { layer.setNeedsDisplay() } }
    }

    @objc public var borderPadding: CGFloat = 0

    @objc public var valueFontSize: CGFloat {
        get { progressLayer.valueFontSize }
        set { progressLayer.valueFontSize = newValue }
    }

    @objc public var fontColor: UIColor {
        get { progressLayer.fontColor }
        set { progressLayer.fontColor = newValue }
    }

    @objc public var progressRotationAngle: CGFloat {
        get { progressLayer.progressRotationAngle }
        set { progressLayer.progressRotationAngle = newValue }
    }

    @objc public var progressAngle: CGFloat {
        get { progressLayer.progressAngle }
        set { progressLayer.progressAngle = newValue }
    }

    @objc public var progressLineWidth: CGFloat {
        get { progressLayer.progressLineWidth }
        set { progressLayer.progressLineWidth = newValue }
    }

    @objc public var progressLinePadding: CGFloat {
        get { progressLayer.progressLinePadding }
        set { progressLayer.progressLinePadding = newValue }
    }

    @objc public var progressColor: UIColor {
        get { progressLayer.progressColor }
        set { progressLayer.progressColor = newValue }
    }

    @objc public var emptyLineWidth: CGFloat {
        get { progressLayer.emptyLineWidth }
        set { progressLayer.emptyLineWidth = newValue }
    }

    @objc public var emptyLineColor: UIColor {
        get { progressLayer.emptyLineColor }
        set { progressLayer.emptyLineColor = newValue }
    }

    @objc public var emptyLineStrokeColor: UIColor {
        get { progressLayer.emptyLineStrokeColor }
        set { progressLayer.emptyLineStrokeColor = newValue }
    }

    @objc public var emptyCapType: Int = 0
    @objc public var textOffset: CGPoint = .zero

    @objc public var countdown: Bool {
        get { progressLayer.countdown }
        set { progressLayer.countdown = newValue }
    }

    @objc public var duration: CGFloat = 0

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    // MARK: - Public

    @objc public func updateProgress(_ value: CGFloat) {
        maxValue = duration
        self.value = value
    }

    // MARK: - CALayer

    public override class var layerClass: AnyClass {
        CircularProgressBarLayer.self
    }

    // MARK: - Private

    private var progressLayer: CircularProgressBarLayer {
        layer as! CircularProgressBarLayer
    }

    private func initView() {
        contentScaleFactor = UIScreen.main.scale
        contentMode = .redraw
        backgroundColor = .black

        progressRotationAngle = 50
        progressColor         = .lightGray
        value                 = 0
        maxValue              = 100
        emptyLineColor        = .lightGray
        emptyLineStrokeColor  = .lightGray
        fontColor             = .lightGray
        emptyLineWidth        = 1
        progressLineWidth     = 5
        progressAngle         = 100
        valueFontSize         = 24
        showValueString       = true
        valueFontName         = "HelveticaNeue-Thin"
        countdown             = false

        isAccessibilityElement = true
        accessibilityLabel     = "CircularProgressView"
        accessibilityValue     = "0"
        accessibilityTraits    = .button
    }
}
