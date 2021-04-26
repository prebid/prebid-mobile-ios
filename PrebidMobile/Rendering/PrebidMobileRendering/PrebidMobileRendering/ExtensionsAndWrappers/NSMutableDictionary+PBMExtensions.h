//
//  NSMutableDictionary+OxmExtensions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Clear)

/// [Mutating] Removes empty vals from the receiver.
- (void)pbmRemoveEmptyVals;

/// Return mutable copy of the receiver with nil values removed.
- (nonnull NSMutableDictionary *)pbmCopyWithoutEmptyVals;

@end
