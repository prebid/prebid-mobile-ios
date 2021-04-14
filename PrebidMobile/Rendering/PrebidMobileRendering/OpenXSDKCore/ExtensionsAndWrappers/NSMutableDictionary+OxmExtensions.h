//
//  NSMutableDictionary+OxmExtensions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Clear)

/// [Mutating] Removes empty vals from the receiver.
- (void)oxmRemoveEmptyVals;

/// Return mutable copy of the receiver with nil values removed.
- (nonnull NSMutableDictionary *)oxmCopyWithoutEmptyVals;

@end
