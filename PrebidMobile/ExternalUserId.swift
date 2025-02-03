/*   Copyright 2020-2021 Prebid.org, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import UIKit

/// Defines the User Id Object from an External Thrid Party Source
/// https://github.com/InteractiveAdvertisingBureau/openrtb/blob/main/extensions/2.x_official_extensions/eids.md
@objcMembers
public class ExternalUserId: NSObject, JSONConvertible {
    
    // MARK: - Properties
    
    /// The source of the external user ID.
    public var source: String
    
    /// Array of extended ID UID objects from the given source.
    public var uids: [UserUniqueID] = []
    
    /// Additional attributes related to the external user ID, represented as an optional dictionary.
    public var ext: [String: Any]?
    
    /// The identifier of the external user ID.
    @available(*, deprecated, message: "Deprecated. This property will be removed in future releases.")
    public var identifier: String?
    
    /// The type of the external user ID, represented as an optional `NSNumber`.
    @available(*, deprecated, message: "Deprecated. This property will be removed in future releases.")
    public var atype: NSNumber?

    // MARK: - Initialization
    
    /// Initializes a new `ExternalUserId` object.
    ///
    /// - Parameters:
    ///   - source: The source of the external user ID (e.g., a third-party provider).
    ///   - uids: A list of `UserUniqueID` objects representing the user's unique identifiers.
    ///   - ext: Optional dictionary for additional attributes related to the external user ID. Default is `nil`.
    public init(source: String, uids: [UserUniqueID], ext: [String: Any]? = nil) {
        self.source = source
        self.uids = uids
        self.ext = ext
        
        super.init()
    }
    
    /// Initialize ExternalUserId Class
    /// - Parameter source: Source of the External User Id String.
    /// - Parameter identifier: String of the External User Id.
    /// - Parameter atype: (Optional) Int of the External User Id.
    /// - Parameter ext: (Optional) Dictionary of the External User Id.
    @available(*, deprecated, message: "Deprecated. This initializer will be removed in future releases.")
    public init(source: String, identifier: String, atype: NSNumber? = nil, ext: [String: Any]? = nil) {
        self.source = source
        self.identifier = identifier
        self.atype = atype
        self.ext = ext
        
        super.init()
    }
    
    /// Converts the `ExternalUserId` instance to a JSON dictionary.
    public func toJSONDictionary() -> [String: Any] {
        guard source.count != 0 else {
            Log.warn("Empty source. Skipping converting to JSON.")
            return [:]
        }
        
        var transformedEUIdDic = [String: Any]()
        transformedEUIdDic["source"] = source
        transformedEUIdDic["ext"] = ext
        
        var uniqueUserIdArray = uids.map { $0.toJSONDictionary() }
        
        // Support deprecated functionality
        if let identifier, let atype {
            let userUniqueID = UserUniqueID(id: identifier, aType: atype)
            uniqueUserIdArray.append(userUniqueID.toJSONDictionary())
        }
        
        transformedEUIdDic["uids"] = uniqueUserIdArray
        
        return transformedEUIdDic
    }
}

/// Extended ID UID objects from the given source.
@objcMembers
public class UserUniqueID: NSObject, JSONConvertible {
    
    /// Cookie or platform-native identifier.
    public var id: String
    
    /// Type of user agent the match is from. It is highly recommended to set this, as many DSPs separate app-native IDs from browser-based IDs and require a type value for ID resolution.
    public var aType: NSNumber
    
    /// Optional vendor-specific extensions.
    public var ext: [String: Any]?
    
    /// Initializes a new UserUniqueID object.
    ///
    /// - Parameters:
    ///   - id: Cookie or platform-native identifier.
    ///   - aType: Type of user agent the match is from. Recommended for DSP ID resolution.
    ///   - ext: Optional vendor-specific extensions. Default is `nil`.
    public init(id: String, aType: NSNumber, ext: [String : Any]? = nil) {
        self.id = id
        self.aType = aType
        self.ext = ext
    }
    
    func toJSONDictionary() -> [String: Any] {
        var ret = [String: Any]()
        
        ret["id"] = id
        ret["atype"] = aType
        ret["ext"] = ext
        
        return ret
    }
}
