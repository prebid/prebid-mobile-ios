/*   Copyright 2018-2021 Prebid.org, Inc.

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

extension NSString {

    @objc(PBMdoesMatch:)
    public func PBMdoesMatch(_ regex: String) -> Bool {
        PBMnumberOfMatches(regex) > 0
    }

    @objc(PBMnumberOfMatches:)
    public func PBMnumberOfMatches(_ regex: String) -> Int32 {
        do {
            let re = try NSRegularExpression(pattern: regex)
            return Int32(re.numberOfMatches(in: self as String, range: NSRange(location: 0, length: length)))
        } catch {
            Log.error("Error \(error.localizedDescription) parsing regex: \(regex)")
            return 0
        }
    }

    @objc(PBMsubstringToString:)
    public func PBMsubstringToString(_ to: String?) -> String? {
        guard let to = to else { return nil }
        let range = range(of: to)
        guard range.location != NSNotFound else { return nil }
        return substring(to: range.location)
    }

    @objc(PBMsubstringFromString:)
    public func PBMsubstringFromString(_ from: String?) -> String? {
        guard let from = from else { return nil }
        let range = range(of: from)
        guard range.location != NSNotFound else { return nil }
        let end = range.location + range.length
        if end < length {
            return substring(with: NSRange(location: end, length: length - range.length))
        }
        return ""
    }

    @objc(PBMsubstringFromString:toString:)
    public func PBMsubstringFromString(_ from: String?, toString to: String?) -> String? {
        guard let from = from, let to = to else { return nil }
        let startRange = range(of: from)
        let endRange   = range(of: to)
        guard startRange.location != NSNotFound, endRange.location != NSNotFound else { return nil }
        let afterFrom = startRange.location + startRange.length
        guard afterFrom <= endRange.location else { return nil }
        return substring(with: NSRange(location: afterFrom, length: endRange.location - afterFrom))
    }

    @objc(PBMstringByReplacingRegex:replaceWith:)
    public func PBMstringByReplacingRegex(_ regex: String?, replaceWith replacement: String?) -> String {
        guard let regex = regex, let replacement = replacement else { return self as String }
        do {
            let re = try NSRegularExpression(pattern: regex)
            return re.stringByReplacingMatches(in: self as String,
                                               range: NSRange(location: 0, length: length),
                                               withTemplate: replacement)
        } catch {
            Log.error("Error \(error.localizedDescription) parsing regex: \(regex)")
            return self as String
        }
    }

    @objc(PBMsubstringFromIndex:toIndex:)
    public func PBMsubstringFromIndex(_ fromIndex: Int32, toIndex: Int32) -> String? {
        guard fromIndex >= 0, toIndex >= 0, Int(toIndex) <= length, fromIndex <= toIndex else { return nil }
        return substring(with: NSRange(location: Int(fromIndex), length: Int(toIndex - fromIndex)))
    }
}
