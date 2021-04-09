//
//  JSONDecoding_PropertyCheck.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension JSONDecoding {
    typealias PropertyCheck<T> = Decoding.PropertyCheck<NSMutableDictionary, T>
}

extension Decoding {
    class PropertyCheck<RawType, BoxedType> {
        let saver: (RawType) -> ()
        let checker: (BoxedType)->()
        
        init(saver: @escaping (RawType) -> (), checker: @escaping (BoxedType) -> ()) {
            self.saver = saver
            self.checker = checker
        }
    }
}
