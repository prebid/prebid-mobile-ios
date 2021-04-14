//
//  ReactiveSdkInitFlag.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import Foundation

class ReactiveSdkInitFlag {
    private(set) var sdkInitialized = false
    private var onSdkInitializedBlock: (() -> ())?
    
    func onSdkInitialized(perform block: @escaping () -> ()) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            if self.sdkInitialized {
                block()
            } else {
                let oldBlock = self.onSdkInitializedBlock
                self.onSdkInitializedBlock = {
                    oldBlock?()
                    block()
                }
            }
        }
    }
    
    func markSdkInitialized() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, !self.sdkInitialized else {
                return
            }
            self.sdkInitialized = true
            let block = self.onSdkInitializedBlock
            self.onSdkInitializedBlock = nil
            block?()
        }
    }
}
