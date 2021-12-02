//
//  OXMBasicParameterBuilder+oxmTestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "PBMBasicParameterBuilder.h"

@interface PBMBasicParameterBuilder()

@property (nonatomic, strong, nullable, readwrite) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong, nullable, readwrite) PBMSDKConfiguration *sdkConfiguration;
@property (nonatomic, strong, nullable, readwrite) PBMTargeting *targeting;
@property (nonatomic, copy, nullable, readwrite) NSString *sdkVersion;

@end
