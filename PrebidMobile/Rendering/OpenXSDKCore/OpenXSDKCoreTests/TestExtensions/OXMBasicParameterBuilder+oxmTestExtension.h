//
//  OXMBasicParameterBuilder+oxmTestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMBasicParameterBuilder.h"

@interface OXMBasicParameterBuilder()

@property (nonatomic, strong, nullable, readwrite) OXMAdConfiguration *adConfiguration;
@property (nonatomic, strong, nullable, readwrite) OXASDKConfiguration *sdkConfiguration;
@property (nonatomic, strong, nullable, readwrite) OXATargeting *targeting;
@property (nonatomic, copy, nullable, readwrite) NSString *sdkVersion;

@end
