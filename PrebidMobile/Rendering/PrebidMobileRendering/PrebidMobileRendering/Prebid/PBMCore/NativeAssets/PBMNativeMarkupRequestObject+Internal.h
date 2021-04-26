//
//  PBMNativeMarkupRequestObject+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeMarkupRequestObject.h"
#import "PBMJsonCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeMarkupRequestObject() <PBMJsonCodable>

@property (nonatomic, copy, nullable, readwrite) NSString *version;

// MARK: - Unsupported properties
@property (nonatomic, strong, nullable) NSNumber *plcmtcnt;
@property (nonatomic, strong, nullable) NSNumber *aurlsupport;
@property (nonatomic, strong, nullable) NSNumber *durlsupport;

@end

NS_ASSUME_NONNULL_END
