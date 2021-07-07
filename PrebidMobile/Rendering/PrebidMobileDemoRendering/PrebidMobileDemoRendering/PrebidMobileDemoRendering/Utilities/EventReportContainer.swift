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

@objc class EventReportContainer: NSObject {
    let button: UIButton
    let container: UIStackView
    
    let dashLabel = UILabel()
    let totalCountLabel = UILabel()
    let leftBracketLabel = UILabel()
    let plusBracketLabel = UILabel()
    let deltaCountLabel = UILabel()
    let rightBracketLabel = UILabel()
    
    private var totalCount = 0
    private var deltaCount = 0
    
    var isEnabled: Bool {
        get {
            return deltaCount == 0
        }
        set {
            if newValue {
                deltaCount += 1
                totalCount += 1
            } else {
                deltaCount = 0
            }
            totalCountLabel.text = "\(totalCount)"
            deltaCountLabel.text = "\(deltaCount)"
            button.isEnabled = newValue
            plusBracketLabel.isHidden = !newValue
        }
    }
    
    @objc func disable() {
        isEnabled = false
    }
    
    override var accessibilityLabel: String? {
        get {
            return button.accessibilityLabel
        }
        set {
            button.accessibilityLabel = newValue
            totalCountLabel.accessibilityLabel = newValue?.appending(" times total")
            deltaCountLabel.accessibilityLabel = newValue?.appending(" times delta")
        }
    }
    
    var accessibilityIdentifier: String? {
        get {
            return button.accessibilityIdentifier
        }
        set {
            button.accessibilityIdentifier = newValue
            totalCountLabel.accessibilityIdentifier = newValue?.appending(" times total")
            deltaCountLabel.accessibilityIdentifier = newValue?.appending(" times delta")
        }
    }
    
    override init() {
        button = ThreadCheckingButton()
        
        dashLabel.text = " - "
        totalCountLabel.text = "0"
        leftBracketLabel.text = " ( "
        plusBracketLabel.text = "+"
        deltaCountLabel.text = "0"
        rightBracketLabel.text = " ) "
        
        container = UIStackView(arrangedSubviews: [
            button,
            dashLabel,
            totalCountLabel,
            leftBracketLabel,
            plusBracketLabel,
            deltaCountLabel,
            rightBracketLabel,
        ]);
        
        super.init()
        
        container.axis = .horizontal
        container.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(disable), for: .touchUpInside)
    }
}
