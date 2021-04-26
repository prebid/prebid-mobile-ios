//
//  PBMORTBAbstractResponse.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBAbstractResponse<__covariant ExtType> : PBMORTBAbstract

@property (nonatomic, strong) ExtType ext;

@end

NS_ASSUME_NONNULL_END
