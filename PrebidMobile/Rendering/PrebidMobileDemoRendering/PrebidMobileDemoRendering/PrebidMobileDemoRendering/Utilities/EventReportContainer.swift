//
//  EnableCountingButton.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

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
