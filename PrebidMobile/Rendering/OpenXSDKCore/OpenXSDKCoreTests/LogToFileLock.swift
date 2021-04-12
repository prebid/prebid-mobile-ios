//
//  LogToFileLock.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

class LogToFileLock {
    private static var locksCount = 0
    private static let queue = DispatchQueue(label: "UtilitiesForTesting_LogToFileLock")
    
    init() {
        LogToFileLock.queue.sync {
            if LogToFileLock.locksCount == 0 {
                UtilitiesForTesting.prepareLogFile()
            }
            LogToFileLock.locksCount += 1
        }
    }
    
    deinit {
        LogToFileLock.queue.sync {
            LogToFileLock.locksCount -= 1
            if LogToFileLock.locksCount == 0 {
                UtilitiesForTesting.releaseLogFile()
            }
        }
    }
}
