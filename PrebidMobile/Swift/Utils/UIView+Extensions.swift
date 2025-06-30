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

import UIKit

extension UIView {
    
    /// A computed property to find the nearest parent view controller in the responder chain.
    var parentViewController: UIViewController? {
        if let nextResponder = next as? UIViewController {
            return nextResponder
        } else if let nextResponder = next as? UIView {
            return nextResponder.parentViewController
        } else {
            return nil
        }
    }
    
    /**
     This is a function to get subviews of a particular type from view recursively.
     It would look recursively in all subviews and return back the subviews of the type T
     */
    public func allSubViewsOf<T: UIView>(type: T.Type) -> [T] {
        var all = [T]()
        
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count > 0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        
        getSubview(view: self)
        return all
    }
    
    @objc(PBMAddFillSuperviewConstraints)
    @_spi(PBMInternal)
    public func addFillSuperviewConstraints() {
        guard let superview = self.superview else { return }

        self.translatesAutoresizingMaskIntoConstraints = false

        let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal,
                                       toItem: superview, attribute: .width,
                                       multiplier: 1.0, constant: 0.0)
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal,
                                        toItem: superview, attribute: .height,
                                        multiplier: 1.0, constant: 0.0)
        let centerX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal,
                                         toItem: superview, attribute: .centerX,
                                         multiplier: 1.0, constant: 0.0)
        let centerY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal,
                                         toItem: superview, attribute: .centerY,
                                         multiplier: 1.0, constant: 0.0)

        let constraints = [width, height, centerX, centerY]
        constraints.forEach { $0.isActive = true }
        superview.addConstraints(constraints)
    }

    @objc(PBMAddConstraintsFromCGRect:)
    @_spi(PBMInternal)
    public func addConstraints(from rect: CGRect) {
        guard let superview = self.superview else { return }

        self.translatesAutoresizingMaskIntoConstraints = false

        let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal,
                                       toItem: nil, attribute: .notAnAttribute,
                                       multiplier: 1.0, constant: rect.size.width)
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal,
                                        toItem: nil, attribute: .notAnAttribute,
                                        multiplier: 1.0, constant: rect.size.height)
        let x = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal,
                                   toItem: superview, attribute: .left,
                                   multiplier: 1.0, constant: rect.origin.x)
        let y = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal,
                                   toItem: superview, attribute: .top,
                                   multiplier: 1.0, constant: rect.origin.y)

        let constraints = [width, height, x, y]
        constraints.forEach { $0.isActive = true }
        superview.addConstraints(constraints)
    }
    
    @objc(pbmIsVisible)
    @_spi(PBMInternal)
    public func isVisible() -> Bool {
        if self.isHidden || self.alpha == 0 || self.window == nil {
            return false
        }
        return self.isVisible(inViewLegacy: self.superview)
    }
    
    @objc(pbmIsVisibleInViewLegacy:)
    @_spi(PBMInternal)
    public func isVisible(inViewLegacy inView: UIView?) -> Bool {
        guard let inView = inView else {
            return true
        }
        
        if inView.superview == inView.window, let siblings = inView.superview?.subviews, siblings.count > 1 {
            for view in siblings.reversed() {
                if view === inView {
                    break
                }
                if view.isSubTreeViewVisible() {
                    return false
                }
            }
        }
        
        let viewFrame = inView.convert(self.bounds, from: self)
        if viewFrame.intersects(inView.bounds) {
            return self.isVisible(inViewLegacy: inView.superview)
        }
        
        return false
    }

    @objc
    private func isSubTreeViewVisible() -> Bool {
        if !self.isHidden && self.alpha > 0 && !self.bounds.size.equalTo(.zero) {
            return true
        }
        
        for view in self.subviews {
            if view.isSubTreeViewVisible() {
                return true
            }
        }
        
        return false
    }
}
