//
//  OXMLocationManager+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMLocationManager.h"

@interface PBMLocationManager (oxmTestExtension)

- (BOOL)locationIsValid:(CLLocation *)location;

@end
