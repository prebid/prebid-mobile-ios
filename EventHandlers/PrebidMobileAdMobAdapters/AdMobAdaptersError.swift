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

enum AdMobAdaptersError {
    case emptyCustomEventExtras
    case noBidInEventExtras
    case noConfigIDInEventExtras
    case noServerParameter
    case emptyUserKeywords
    case wrongUserKeywordsFormat
    case emptyServerParameter
    case wrongServerParameterFormat
    case wrongServerParameter
}

extension AdMobAdaptersError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            
        case .emptyCustomEventExtras        : return "The custom event extras is empty"
        case .noBidInEventExtras            : return "The Bid object is absent in the extras"
        case .noConfigIDInEventExtras       : return "The Config ID is absent in the extras"
        case .noServerParameter             : return "Server parameter is absent in request"
        case .emptyUserKeywords             : return "User keywords are empty"
        case .wrongUserKeywordsFormat       : return "User keywords are in a wrong format"
        case .emptyServerParameter          : return "The server parameter is empty"
        case .wrongServerParameterFormat    : return "The server parameter is in a wrong format"
        case .wrongServerParameter          : return "User keywords don't not contain server parameter"
        }
    }
}
