//
//  PBMORTBRegs.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.3: Regs

//This object contains any legal, governmental, or industry regulations that apply to the request. The
//coppa flag signals whether or not the request falls under the United States Federal Trade Commission’s
//regulations for the United States Children’s Online Privacy Protection Act (“COPPA”).
@interface PBMORTBRegs : PBMORTBAbstract
    
//Int. Flag indicating if this request is subject to the COPPA regulations established by the USA FTC, where 0 = no, 1 = yes
@property (nonatomic, strong, nullable) NSNumber *coppa;

/// Placeholder for exchange-specific extensions to OpenRTB.
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, id> *ext;

@end

NS_ASSUME_NONNULL_END
