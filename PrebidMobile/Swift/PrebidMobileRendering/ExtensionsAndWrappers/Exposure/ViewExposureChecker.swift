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

@objc(PBMViewExposureChecker) @_spi(PBMInternal) public
class ViewExposureChecker: NSObject {

    @objc(exposureOfView:)
    public static func exposure(of view: UIView) -> ViewExposure {
        ViewExposureChecker(view: view).exposure
    }

    private weak var testedView: UIView?
    private var clippedRect: CGRect = .zero
    private var obstructions: [NSValue] = []

    @objc(initWithView:)
    public init(view: UIView) {
        self.testedView = view
        super.init()
    }

    @objc public var exposure: ViewExposure {
        guard let view = testedView else { return Factory.ViewExposureType.zeroExposure() }

        clippedRect  = view.bounds
        obstructions = []

#if DEBUG
        if (Prebid.shared.value(forKey: "forcedIsViewable") as? Bool) == true {
            return Factory.createViewExposure(exposureFactor: 1, visibleRectangle: view.bounds, occlusionRectangles: nil)
        }
#endif

        guard !view.isHidden, view.superview != nil, isOnForeground() else {
            return Factory.ViewExposureType.zeroExposure()
        }

        guard let parent = view.superview,
              visitParent(parent, fromChild: view),
              collapseBoundingBox() else {
            return Factory.ViewExposureType.zeroExposure()
        }

        let occRects  = buildObstructionRects()
        let fullArea  = Float(view.bounds.width * view.bounds.height)
        let clipArea  = Float(clippedRect.width * clippedRect.height)
        let blocked   = (occRects ?? []).reduce(Float(0)) { $0 + Float($1.cgRectValue.width * $1.cgRectValue.height) }

        return Factory.createViewExposure(
            exposureFactor: (clipArea - blocked) / fullArea,
            visibleRectangle: clippedRect,
            occlusionRectangles: occRects
        )
    }

    // MARK: - Private

    private func isOnForeground() -> Bool {
        guard let window = testedView?.window else { return false }
        guard UIApplication.shared.applicationState == .active else { return false }
        if #available(iOS 13.0, *) {
            return window.windowScene?.activationState == .foregroundActive
        }
        return true
    }

    @discardableResult
    private func visitParent(_ parent: UIView, fromChild child: UIView) -> Bool {
        guard !parent.isHidden else { return false }
        guard let view = testedView else { return false }

        let clip = parent.clipsToBounds || (parent === view.window)
        if clip {
            clippedRect = clippedRect.intersection(view.convert(parent.bounds, from: parent))
            if clippedRect.isEmpty { return false }
        }

        if let grandparent = parent.superview {
            guard visitParent(grandparent, fromChild: parent) else { return false }
        }

        let subs = parent.subviews
        if let idx = subs.firstIndex(of: child) {
            for i in (idx + 1)..<subs.count {
                collectObstructions(from: subs[i])
            }
        }
        return true
    }

    private func collectObstructions(from view: UIView) {
        guard !shouldIgnore(view) else { return }
        testForObstructing(view)
        if view.clipsToBounds { return }
        for sub in view.subviews { collectObstructions(from: sub) }
    }

    private func testForObstructing(_ view: UIView) {
        guard let tested = testedView else { return }
        let testRect     = tested.convert(view.bounds, from: view)
        let intersection = clippedRect.intersection(testRect)
        if !intersection.isEmpty {
            obstructions.append(NSValue(cgRect: intersection))
        }
    }

    private func collapseBoundingBox() -> Bool {
        let old = clippedRect
        guard !old.isEmpty else { return false }

        var current: [NSValue] = [NSValue(cgRect: clippedRect)]
        var next:    [NSValue] = []

        for obs in obstructions {
            removeRect(obs.cgRectValue, from: current, into: &next, startingAt: 0)
            swap(&current, &next)
            next.removeAll()
            if current.isEmpty { clippedRect = .zero; return false }
        }

        var result = CGRect.zero
        for (i, val) in current.enumerated() {
            result = i == 0 ? val.cgRectValue : result.union(val.cgRectValue)
        }

        if result == old { return true }
        clippedRect = result

        var removed = 0
        for i in 0..<obstructions.count {
            let rect = obstructions[i].cgRectValue
            if result.intersects(rect) {
                let trimmed = !result.contains(rect) ? result.intersection(rect) : nil
                obstructions[i - removed] = trimmed.map { NSValue(cgRect: $0) } ?? obstructions[i]
            } else {
                removed += 1
            }
        }
        if removed > 0 { obstructions.removeLast(removed) }
        return true
    }

    private func removeRect(_ rect: CGRect, from src: [NSValue], into dst: inout [NSValue], startingAt first: Int) {
        for i in first..<src.count {
            fragmentize(src[i].cgRectValue, around: rect, into: &dst)
        }
    }

    private func buildObstructionRects() -> [NSValue]? {
        guard !obstructions.isEmpty else { return nil }

        var current   = obstructions
        var remaining: [NSValue] = []
        var picked:    [NSValue] = []

        while !current.isEmpty {
            current.sort { a, b in
                let aArea = a.cgRectValue.width * a.cgRectValue.height
                let bArea = b.cgRectValue.width * b.cgRectValue.height
                return aArea > bArea
            }
            let next = current[0]
            picked.append(next)
            removeRect(next.cgRectValue, from: current, into: &remaining, startingAt: 1)
            swap(&current, &remaining)
            remaining.removeAll()
        }
        return picked.isEmpty ? nil : picked
    }

    private func fragmentize(_ val: CGRect, around rect: CGRect, into array: inout [NSValue]) {
        if !val.intersects(rect) { array.append(NSValue(cgRect: val)); return }
        if rect.contains(val)    { return }

        let trimmed = rect.intersection(val)
        let pieces: [CGRect] = [
            CGRect(x: val.minX, y: val.minY, width: trimmed.minX - val.minX,   height: val.height),
            CGRect(x: trimmed.minX, y: val.minY, width: trimmed.width,           height: trimmed.minY - val.minY),
            CGRect(x: trimmed.minX, y: trimmed.maxY, width: trimmed.width,        height: val.maxY - trimmed.maxY),
            CGRect(x: trimmed.maxX, y: val.minY, width: val.maxX - trimmed.maxX, height: val.height),
        ]
        for piece in pieces where !piece.isEmpty {
            array.append(NSValue(cgRect: piece))
        }
    }

    private func shouldIgnore(_ view: UIView) -> Bool {
        if view.isHidden { return true }
        let systemClasses: [AnyClass] = [
            UITabBar.self, UITabBarController.self,
            UINavigationBar.self, UINavigationController.self,
            UIToolbar.self, UISearchBar.self,
        ]
        return systemClasses.contains { isDescendant(view, of: $0) }
    }

    private func isDescendant(_ view: UIView, of cls: AnyClass) -> Bool {
        var current: UIView? = view
        while let v = current {
            if v.isKind(of: cls) { return true }
            current = v.superview
        }
        var responder: UIResponder? = view.next
        while let r = responder {
            if r.isKind(of: cls) { return true }
            responder = r.next
        }
        return false
    }
}
