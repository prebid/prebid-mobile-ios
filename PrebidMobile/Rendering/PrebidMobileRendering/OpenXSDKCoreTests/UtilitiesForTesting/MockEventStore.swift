//
//  MockEventStore.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import UIKit
import EventKitUI

class MockEventStore: EKEventStore {

    var requestAccessGrantedResult = false

    override func requestAccess(to entityType: EKEntityType,
                       completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        
        completion(requestAccessGrantedResult, nil)
        return
    }
}
