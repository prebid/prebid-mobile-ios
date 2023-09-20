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

@objc(PBMAdViewButtonDecorator) @objcMembers
public class AdViewButtonDecorator: NSObject {
    
    // MARK: - Public proprties
    
    public var button: UIButton
    public var buttonPosition: Position
    public var customButtonPosition: CGRect
    public var buttonArea: Double
    
    public var isMRAID: Bool
    
    public var buttonTouchUpInsideBlock: PBMVoidBlock?
    
    public override init() {
        button = UIButton()
        customButtonPosition = .zero
        buttonPosition = .topRight
        isMRAID = false
        buttonArea = PBMConstants.BUTTON_AREA_DEFAULT.doubleValue
        super.init()
    }
    
    public func setImage(_ image: UIImage) {
        buttonImage = image
        button.setImage(buttonImage, for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
    }
    
    public func addButton(to view: UIView, displayView: UIView) {
        self.displayView = displayView
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTappedAction), for: .touchUpInside)
        view.addSubview(button)
        updateButtonConstraints()
    }
    
    public func removeButtonFromSuperview() {
        button.removeFromSuperview()
    }
    
    public func bringButtonToFront() {
        button.superview?.bringSubviewToFront(button)
    }
    
    public func sendSubviewToBack() {
        button.superview?.sendSubviewToBack(button)
    }
    
    public func updateButtonConstraints() {
        button.superview?.removeConstraints(activeConstraints ?? [])
        activeConstraints = createButtonConstraints()
        button.superview?.addConstraints(activeConstraints ?? [])
    }
    
    public func getButtonConstraintConstant() -> CGFloat {
        let screenWidth = UIApplication.shared.statusBarOrientation.isPortrait ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
        var btnConstraintConstant = (screenWidth * buttonArea) / 2
        
        if btnConstraintConstant > 30 || btnConstraintConstant < 5 {
            btnConstraintConstant = PBMConstants.buttonConstraintConstant.doubleValue
        }
        
        return isMRAID ? 0 : btnConstraintConstant
    }
    
    public func getButtonSize() -> CGSize {
        let screenWidth = UIApplication.shared.statusBarOrientation.isPortrait ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
        let btnSizeValue = screenWidth * buttonArea
        return CGSize(width: btnSizeValue, height: btnSizeValue)
    }
    
    public func buttonTappedAction() {
        if let buttonTouchUpInsideBlock = buttonTouchUpInsideBlock {
            buttonTouchUpInsideBlock()
        }
    }
    
    // MARK: - Internal Methods
    
    func createButtonConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        let constant = getButtonConstraintConstant()
        let size = getButtonSize()
        
        let width = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: size.width)
        let height = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: size.height)

        let top = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: displayView, attribute: .top, multiplier: 1.0, constant: constant)
        let bottom = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: displayView, attribute: .bottom, multiplier: 1.0, constant: -constant)
        let centerY = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: displayView, attribute: .centerY, multiplier: 1.0, constant: 0)

        let right = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: displayView, attribute: .right, multiplier: 1.0, constant: -constant)
        let left = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: displayView, attribute: .left, multiplier: 1.0, constant: constant)
        let centerX = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: displayView, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        switch buttonPosition {
        case .topLeft:
            constraints = [width, height, top, left]
        case .topRight:
            constraints = [width, height, top, right]
        case .topCenter:
            constraints = [width, height, top, centerX]
        case .center:
            constraints = [width, height, centerY, centerX]
        case .bottomLeft:
            constraints = [width, height, bottom, left]
        case .bottomCenter:
            constraints = [width, height, bottom, centerX]
        case .bottomRight:
            constraints = [width, height, bottom, right]
        case .custom:
            let customWidth = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: customButtonPosition.size.width)
            let customHeight = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: customButtonPosition.size.height)
            let customTop = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: displayView, attribute: .top, multiplier: 1.0, constant: customButtonPosition.origin.y)
            let customLeft = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: displayView, attribute: .left, multiplier: 1.0, constant: customButtonPosition.origin.x)
            
            constraints = [customWidth, customHeight, customTop, customLeft]
        case .undefined:
            break
        @unknown default:
            break
        }
        
        return constraints
    }
    
    // MARK: - Private properties
    private weak var displayView: UIView?
    private var buttonImage: UIImage?
    private var activeConstraints: [NSLayoutConstraint]?
}
