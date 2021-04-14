//
//  NSString+OxmExtensions.h
//  AppObjC
//
//  Copyright © 2018 OpenX, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(OxmExtensions)
- (BOOL) OXMdoesMatch: (nonnull NSString *) regex NS_SWIFT_NAME(OXMdoesMatch(_:));
- (int)  OXMnumberOfMatches: (nonnull NSString *) regex NS_SWIFT_NAME(OXMnumberOfMatches(_:));
- (nullable NSString *) OXMsubstringToString: (nonnull NSString *) to NS_SWIFT_NAME(OXMsubstringToString(_:));
- (nullable NSString *) OXMsubstringFromString: (nonnull NSString *) from NS_SWIFT_NAME(OXMsubstringFromString(_:));
- (nullable NSString *) OXMsubstringFromString: (nonnull NSString *) from toString:(nonnull NSString *) to NS_SWIFT_NAME(OXMsubstringFromString(_:toString:));
- (nonnull NSString *) OXMstringByReplacingRegex: (nonnull NSString *) regex replaceWith:(nonnull NSString *) replaceWithString NS_SWIFT_NAME(OXMstringByReplacingRegex(_:replaceWith:));
- (nullable NSString *) OXMsubstringFromIndex: (int) fromIndex toIndex: (int) toIndex NS_SWIFT_NAME(OXMsubstringFromIndex(_:toIndex:));
@end

