//
//  GADAdSize+Equatable.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import GoogleMobileAds
@testable import PrebidMobileGAMEventHandlers

extension GADAdSize: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.size == rhs.size
    }
}
