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

@objcMembers
public class ContextSubType: SingleContainerInt {
    
    public static let General = ContextSubType(10)

    public static let Article = ContextSubType(11)

    public static let Video = ContextSubType(12)

    public static let Audio = ContextSubType(13)

    public static let Image = ContextSubType(14)

    public static let UserGenerated = ContextSubType(15)

    public static let Social = ContextSubType(20)

    public static let email = ContextSubType(21)

    public static let chatIM = ContextSubType(22)

    public static let SellingProduct = ContextSubType(30)

    public static let AppStore = ContextSubType(31)

    public static let ReviewSite = ContextSubType(32)

    public static let Custom = ContextSubType(500)
}
