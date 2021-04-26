//
//  NSString+OxmExtensions.h
//  AppObjC
//
//  Copyright © 2018 OpenX, Inc. All rights reserved.
//

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

