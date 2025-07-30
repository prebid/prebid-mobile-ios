/*   Copyright 2018-2021 Prebid.org, Inc.
 
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

import Foundation

/// Native context subtype asset.
@objcMembers
public class ContextSubType: SingleContainerInt {
    
    /// Represents a general context type.
    public static let General = ContextSubType(10)
    
    
    /// Represents an article context type.
    public static let Article = ContextSubType(11)
    
    /// Represents a video context type.
    public static let Video = ContextSubType(12)
    
    /// Represents an audio context type.
    public static let Audio = ContextSubType(13)
    
    /// Represents an image context type.
    public static let Image = ContextSubType(14)
    
    /// Represents a user-generated content context type.
    public static let UserGenerated = ContextSubType(15)
    
    /// Represents a social media context type.
    public static let Social = ContextSubType(20)
    
    /// Represents an email context type.
    public static let email = ContextSubType(21)
    
    /// Represents a chat or instant messaging context type.
    public static let chatIM = ContextSubType(22)
    
    /// Represents a product selling context type.
    public static let SellingProduct = ContextSubType(30)
    
    /// Represents an App Store context type.
    public static let AppStore = ContextSubType(31)
    
    /// Represents a review site context type.
    public static let ReviewSite = ContextSubType(32)
    
    /// Represents a custom context type.
    public static let Custom = ContextSubType(500)
}
