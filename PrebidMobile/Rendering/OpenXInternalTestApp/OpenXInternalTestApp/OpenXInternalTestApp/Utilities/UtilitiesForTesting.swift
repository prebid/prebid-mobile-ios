//
//  UtilitiesForTesting.swift
//  OpenXInternalTestApp
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation

class UtilitiesForTesting {
    class func loadFileAsDataFromBundle(_ fileName:String) -> Data? {
        let bundlePath = Bundle.main.resourcePath!
        var url = URL(fileURLWithPath: bundlePath)
        url.appendPathComponent(fileName)
        
        let ret = try? Data(contentsOf: url)
        return ret
    }

    class func loadFileAsStringFromBundle(_ fileName:String) -> String? {
        guard let data = loadFileAsDataFromBundle(fileName) else {
            return nil
        }
        
        let ret = String(data: data, encoding: String.Encoding.utf8)
        return ret
    }
}

