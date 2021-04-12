//
//  OXMORTBAbstractResponse.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXMORTBAbstractResponse<__covariant ExtType> : OXMORTBAbstract

@property (nonatomic, strong) ExtType ext;

@end

NS_ASSUME_NONNULL_END
