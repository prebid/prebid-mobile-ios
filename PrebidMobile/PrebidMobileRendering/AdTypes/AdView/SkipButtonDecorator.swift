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

@objcMembers
public class SkipButtonDecorator: AdViewButtonDecorator {
    
    // MARK: Public proprties
        
    public override init() {
        super.init()
        buttonArea = PBMConstants.SKIP_BUTTON_AREA_DEFAULT.doubleValue
        button.accessibilityIdentifier = "PBMSkip"
    }
    
    public override func getButtonConstraintConstant() -> CGFloat {
        var btnConstraintConstant = (UIScreen.main.bounds.size.width * buttonArea) / 2
        
        if btnConstraintConstant > 30 || btnConstraintConstant < 5 {
            btnConstraintConstant = 15
        }
        
        return isMRAID ? 0 : btnConstraintConstant
    }
    
    public override func getButtonSize() -> CGSize {
        let btnSizeValue = UIScreen.main.bounds.size.width * buttonArea
        return CGSize(width: btnSizeValue, height: btnSizeValue)
    }
}
