//
//  UserDefaultsBacked.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/// Property wrapper for properties that are backed by `UserDefaults`
@propertyWrapper
struct UserDefaultsBacked<Value> {
    /// The key used to access the `UserDefaults` entry.
    let key: String
    
    /// Default value when the `key` doesn't exist.
    let defaultValue: Value
    
    /// `UserDefaults` instance to use. By default, this will be `.standard`.
    var storage: UserDefaults = .standard

    // MARK: - @propertyWrapper
    
    var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
