//
//  ThreadCheckingButton.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit

class ThreadCheckingButton: UIButton {
    override var isEnabled: Bool {
        set {
            assert(Thread.current.isMainThread)
            super.isEnabled = newValue
        }
        get {
            return super.isEnabled
        }
    }
}
