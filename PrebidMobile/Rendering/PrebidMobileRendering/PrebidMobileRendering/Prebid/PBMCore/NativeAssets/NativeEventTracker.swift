//
//  NativeEventTracker.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeEventTracker : NSObject, NSCopying, PBMJsonCodable {
    
    /// [Required]
    /// Type of event available for tracking.
    /// See NativeEventType
    @objc public var event: Int
    
    /// [Required]
    /// Array of the types of tracking available for the given event.
    /// See NativeEventTrackingMethod
    @objc public var methods: [Int]
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
    @objc public var ext: [String : Any]?
    
    // MARK: - Private Properties
    
    @objc public init(event: Int, methods:[Int]) {
        self.event = event
        self.methods = methods
    }
    
    @objc public func setExt(_ ext: [String : Any]?) throws {
        guard let ext = ext else {
            self.ext = nil
            return
        }
        self.ext = try NSDictionary(dictionary: ext).unserializedCopy()
    }
    
    private override init()  {
        fatalError()
    }
    
    // MARK: - NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let clone = NativeEventTracker(event: event, methods: methods)
        return clone
    }
    
    // MARK: - PBMJsonCodable
    
    public var jsonDictionary: [String : Any]? {
        var result = [String : Any]()
        result["event"] = event
        result["ext"] = ext
        result["methods"] = methods
        
        return result
    }
    
    public func toJsonString() throws -> String {
        try PBMFunctions.toStringJsonDictionary(jsonDictionary ?? [:])
    }
}
