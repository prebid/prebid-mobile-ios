//
//  OXANativeMarkupRequestObject+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeMarkupRequestObject.h"
#import "OXAJsonCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeMarkupRequestObject() <OXAJsonCodable>

@property (nonatomic, copy, nullable, readwrite) NSString *version;

// MARK: - Unsupported properties
@property (nonatomic, strong, nullable) NSNumber *plcmtcnt;
@property (nonatomic, strong, nullable) NSNumber *aurlsupport;
@property (nonatomic, strong, nullable) NSNumber *durlsupport;

@end

NS_ASSUME_NONNULL_END
