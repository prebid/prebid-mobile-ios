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

// ObjC class name preserved so Factory.ViewExposureType = NSClassFromString("PBMViewExposure_Objc") resolves at runtime
@objc(PBMViewExposure_Objc) @_spi(PBMInternal) public
class ViewExposureImpl: NSObject, ViewExposure {

    public let exposureFactor: Float
    public let visibleRectangle: CGRect
    public let occlusionRectangles: [NSValue]?

    public required init(exposureFactor: Float,
                         visibleRectangle: CGRect,
                         occlusionRectangles: [NSValue]?) {
        self.exposureFactor      = exposureFactor
        self.visibleRectangle    = visibleRectangle
        self.occlusionRectangles = occlusionRectangles
        super.init()
    }

    public static func zeroExposure() -> ViewExposure {
        struct Once { static let value: ViewExposure = Factory.createViewExposure(exposureFactor: 0, visibleRectangle: .zero, occlusionRectangles: nil) }
        return Once.value
    }

    public var exposedPercentage: Float { exposureFactor * 100 }

    // MARK: - NSObject overrides

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ViewExposureImpl else { return false }
        return self === other
            || (exposureFactor == other.exposureFactor
                && visibleRectangle == other.visibleRectangle
                && (occlusionRectangles == other.occlusionRectangles
                    || occlusionRectangles == nil && other.occlusionRectangles == nil
                    || (occlusionRectangles?.elementsEqual(other.occlusionRectangles ?? []) ?? false)))
    }

    public override var hash: Int {
        var h = 0
        h ^= NSNumber(value: exposureFactor).hash
        h ^= NSValue(cgRect: visibleRectangle).hash
        h ^= (occlusionRectangles as NSArray?)?.hash ?? 0
        return h
    }

    public override var description: String {
        serializeWith(nulls: false, escapeQuotes: false, usePercentages: false) { s, f in
            s.append(String(format: "%5.3f", f))
        }
    }

    // MARK: - ViewExposure

    public func serialize(withFormatter formatter: NumberFormatter) -> String {
        serializeWith(nulls: true, escapeQuotes: true, usePercentages: true) { s, f in
            s.append(formatter.string(from: NSNumber(value: f)) ?? "\(f)")
        }
    }

    // MARK: - Private

    private func serializeWith(nulls: Bool, escapeQuotes: Bool, usePercentages: Bool,
                                floatAppender: (inout String, Float) -> Void) -> String {
        let q = escapeQuotes ? "\\\"" : "\""
        var desc = "{"
        desc += q + (usePercentages ? "exposedPercentage" : "exposureFactor") + q + ": "
        floatAppender(&desc, exposedPercentage)
        desc += ", " + q + "visibleRectangle" + q + ": "
        appendRect(visibleRectangle, to: &desc, quote: q, floatAppender: floatAppender)
        if nulls || occlusionRectangles != nil {
            desc += ", " + q + "occlusionRectangles" + q + ": "
            if let rects = occlusionRectangles {
                desc += "["
                for (index, value) in rects.enumerated() {
                    if index > 0 { desc += ", " }
                    appendRect(value.cgRectValue, to: &desc, quote: q, floatAppender: floatAppender)
                }
                desc += "]"
            } else {
                desc += "null"
            }
        }
        desc += "}"
        return desc
    }

    private func appendRect(_ rect: CGRect, to string: inout String, quote: String,
                             floatAppender: (inout String, Float) -> Void) {
        string += "{"
        string += quote + "x" + quote + ": "; floatAppender(&string, Float(rect.origin.x))
        string += ", " + quote + "y" + quote + ": "; floatAppender(&string, Float(rect.origin.y))
        string += ", " + quote + "width" + quote + ": "; floatAppender(&string, Float(rect.size.width))
        string += ", " + quote + "height" + quote + ": "; floatAppender(&string, Float(rect.size.height))
        string += "}"
    }
}
