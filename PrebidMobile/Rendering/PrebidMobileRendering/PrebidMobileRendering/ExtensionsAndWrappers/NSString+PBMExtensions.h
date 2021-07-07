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

#import <Foundation/Foundation.h>

@interface NSString(PBMExtensions)
- (BOOL) PBMdoesMatch: (nonnull NSString *) regex NS_SWIFT_NAME(PBMdoesMatch(_:));
- (int)  PBMnumberOfMatches: (nonnull NSString *) regex NS_SWIFT_NAME(PBMnumberOfMatches(_:));
- (nullable NSString *) PBMsubstringToString: (nonnull NSString *) to NS_SWIFT_NAME(PBMsubstringToString(_:));
- (nullable NSString *) PBMsubstringFromString: (nonnull NSString *) from NS_SWIFT_NAME(PBMsubstringFromString(_:));
- (nullable NSString *) PBMsubstringFromString: (nonnull NSString *) from toString:(nonnull NSString *) to NS_SWIFT_NAME(PBMsubstringFromString(_:toString:));
- (nonnull NSString *) PBMstringByReplacingRegex: (nonnull NSString *) regex replaceWith:(nonnull NSString *) replaceWithString NS_SWIFT_NAME(PBMstringByReplacingRegex(_:replaceWith:));
- (nullable NSString *) PBMsubstringFromIndex: (int) fromIndex toIndex: (int) toIndex NS_SWIFT_NAME(PBMsubstringFromIndex(_:toIndex:));
@end

