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
import QuartzCore

@objc(PBMCircularProgressBarLayer)
public class CircularProgressBarLayer: CALayer {

    @NSManaged @objc public var value: CGFloat

    @objc public var progressAngle: CGFloat        = 0
    @objc public var progressRotationAngle: CGFloat = 0
    @objc public var maxValue: CGFloat             = 0
    @objc public var animationDuration: TimeInterval = 0
    @objc public var valueFontSize: CGFloat        = 0
    @objc public var unitFontSize: CGFloat         = 0
    @objc public var fontColor: UIColor            = .white
    @objc public var progressLineWidth: CGFloat    = 0
    @objc public var progressColor: UIColor        = .white
    @objc public var emptyLineWidth: CGFloat       = 0
    @objc public var progressLinePadding: CGFloat  = 0
    @objc public var emptyLineColor: UIColor       = .white
    @objc public var emptyLineStrokeColor: UIColor = .white
    @objc public var valueFontName: String         = ""
    @objc public var showValueString: Bool         = false
    @objc public var countdown: Bool               = false

    // MARK: - CALayer

    public override class func needsDisplay(forKey key: String) -> Bool {
        key == "value" || super.needsDisplay(forKey: key)
    }

    public override func draw(in context: CGContext) {
        super.draw(in: context)
        UIGraphicsPushContext(context)
        let rect = context.boundingBoxOfClipPath
        setupBackgroundShape(rect)
        drawProgressBar(rect, context: context)
        if showValueString { drawText(rect) }
        UIGraphicsPopContext()
    }

    // MARK: - Private

    private func setupBackgroundShape(_ rect: CGRect) {
        let maskingShape = CAShapeLayer()
        maskingShape.path = UIBezierPath(ovalIn: rect).cgPath
        self.mask = maskingShape
    }

    private func drawProgressBar(_ rect: CGRect, context: CGContext) {
        guard progressLineWidth > 0 else { return }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width  = rect.width
        let height = rect.height
        var radius = min(width, height) / 2
        radius -= max(emptyLineWidth, progressLineWidth) / 2
        radius -= progressLinePadding

        let arc = CGMutablePath()
        arc.addArc(center: center,
                   radius: radius,
                   startAngle: (progressAngle / 100) * .pi
                       - ((-progressRotationAngle / 100) * 2 + 0.5) * .pi
                       - (2 * .pi) * (progressAngle / 100) * (100 - 100 * value / maxValue) / 100,
                   endAngle: -(progressAngle / 100) * .pi
                       - ((-progressRotationAngle / 100) * 2 + 0.5) * .pi,
                   clockwise: true)

        let strokedArc = arc.copy(strokingWithWidth: progressLineWidth,
                                  lineCap: .round,
                                  lineJoin: .miter,
                                  miterLimit: 10)

        context.addPath(strokedArc)
        context.setFillColor(progressColor.cgColor)
        context.setStrokeColor(progressColor.cgColor)
        context.drawPath(using: .fillStroke)
    }

    private func drawText(_ rect: CGRect) {
        guard value > 1 else { return }

        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center

        let fontSize = valueFontSize == -1 ? rect.height / 5 : valueFontSize
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fontColor,
            .paragraphStyle: textStyle
        ]

        let displayValue = countdown ? (maxValue - value) : value
        let text = NSAttributedString(string: String(format: "%.0f", displayValue), attributes: attributes)
        let textSize = text.size()
        let textOrigin = CGPoint(x: rect.midX - textSize.width / 2,
                                 y: rect.midY - textSize.height / 2)
        text.draw(at: textOrigin)
    }
}
