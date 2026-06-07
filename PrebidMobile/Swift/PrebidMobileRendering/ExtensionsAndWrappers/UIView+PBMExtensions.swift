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

extension UIView {

    @objc(PBMAddCropAndCenterConstraintsWithInitialWidth:initialHeight:)
    public func PBMAddCropAndCenterConstraints(initialWidth: CGFloat, initialHeight: CGFloat) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        let centerX = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        let centerY = centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        let maxW = widthAnchor.constraint(lessThanOrEqualTo: superview.widthAnchor)
        let maxH = heightAnchor.constraint(lessThanOrEqualTo: superview.heightAnchor)
        let prefW = widthAnchor.constraint(equalToConstant: initialWidth)
        prefW.priority = .defaultHigh
        let prefH = heightAnchor.constraint(equalToConstant: initialHeight)
        prefH.priority = .defaultHigh

        NSLayoutConstraint.activate([centerX, centerY, maxW, maxH, prefW, prefH])
        superview.addConstraints([centerX, centerY, maxW, maxH, prefW, prefH])
    }

    @objc(PBMAddBottomRightConstraintsWithMarginSize:)
    public func PBMAddBottomRightConstraintsWithMarginSize(_ marginSize: CGSize) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        let right  = rightAnchor.constraint(equalTo: superview.rightAnchor,  constant: marginSize.width)
        let bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: marginSize.height)
        NSLayoutConstraint.activate([right, bottom])
        superview.addConstraints([right, bottom])
    }

    @objc(PBMAddBottomRightConstraintsWithViewSize:marginSize:)
    public func PBMAddBottomRightConstraints(viewSize: CGSize, marginSize: CGSize) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        let w      = widthAnchor.constraint(equalToConstant: viewSize.width)
        let h      = heightAnchor.constraint(equalToConstant: viewSize.height)
        let right  = rightAnchor.constraint(equalTo: superview.rightAnchor,  constant: marginSize.width)
        let bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: marginSize.height)
        NSLayoutConstraint.activate([w, h, right, bottom])
        superview.addConstraints([w, h, right, bottom])
    }

    @objc(PBMAddBottomLeftConstraintsWithViewSize:marginSize:)
    public func PBMAddBottomLeftConstraints(viewSize: CGSize, marginSize: CGSize) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        let w      = widthAnchor.constraint(equalToConstant: viewSize.width)
        let h      = heightAnchor.constraint(equalToConstant: viewSize.height)
        let left   = leftAnchor.constraint(equalTo: superview.leftAnchor,    constant: marginSize.width)
        let bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: marginSize.height)
        NSLayoutConstraint.activate([w, h, left, bottom])
        superview.addConstraints([w, h, left, bottom])
    }

    @objc(PBMAddTopRightConstraintsWithViewSize:marginSize:)
    public func PBMAddTopRightConstraints(viewSize: CGSize, marginSize: CGSize) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        let w     = widthAnchor.constraint(equalToConstant: viewSize.width)
        let h     = heightAnchor.constraint(equalToConstant: viewSize.height)
        let right = rightAnchor.constraint(equalTo: superview.rightAnchor, constant: marginSize.width)
        let top   = topAnchor.constraint(equalTo: superview.topAnchor,     constant: marginSize.height)
        NSLayoutConstraint.activate([w, h, right, top])
        superview.addConstraints([w, h, right, top])
    }

    @objc(PBMAddTopLeftConstraintsWithViewSize:marginSize:)
    public func PBMAddTopLeftConstraints(viewSize: CGSize, marginSize: CGSize) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        let w    = widthAnchor.constraint(equalToConstant: viewSize.width)
        let h    = heightAnchor.constraint(equalToConstant: viewSize.height)
        let left = leftAnchor.constraint(equalTo: superview.leftAnchor, constant: marginSize.width)
        let top  = topAnchor.constraint(equalTo: superview.topAnchor,   constant: marginSize.height)
        NSLayoutConstraint.activate([w, h, left, top])
        superview.addConstraints([w, h, left, top])
    }

    @objc(LogViewHierarchy)
    public func logViewHierarchy() {
        Log.info("**********LOGGING VIEW HIERARCHY**********")
        logHierarchyRecursive(view: self, depth: 0)
    }

    @objc(pbmIsVisibleInView:)
    public func pbmIsVisibleInView(_ inView: UIView) -> Bool {
        viewExposure.exposureFactor > 0
    }

    // MARK: - Private

    private func logHierarchyRecursive(view: UIView, depth: Int) {
        let prefix = String(repeating: "-", count: depth)
        Log.info("\(prefix)view = \(view) view.constraints: \(view.constraints)")
        for sub in view.subviews {
            logHierarchyRecursive(view: sub, depth: depth + 1)
        }
    }
}
