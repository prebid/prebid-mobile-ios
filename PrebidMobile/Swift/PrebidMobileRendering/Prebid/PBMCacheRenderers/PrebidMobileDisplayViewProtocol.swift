//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
import Foundation

// Don't add `where Self: UIView` here. Swift prints that constraint on an @objc protocol
// into the .swiftinterface as `: UIKit.UIView`, which doesn't compile, so importing the
// XCFramework fails. APIs that need a view use `UIView & PrebidMobileDisplayViewProtocol`.

/// This protocol is used to load and display the ad content in a view.
/// Conforming types are expected to be `UIView` subclasses.
@objc public protocol PrebidMobileDisplayViewProtocol {
    
    /// Loads the ad content into the display view.
    /// - Important: This method is expected to call the `loadingDelegate` once the
    /// ad is successfully loaded or if any error occurred.
    func loadAd()
    
}
