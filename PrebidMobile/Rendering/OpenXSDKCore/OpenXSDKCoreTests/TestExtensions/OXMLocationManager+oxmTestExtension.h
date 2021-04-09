//
//  OXMLocationManager+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMLocationManager.h"

@interface OXMLocationManager (oxmTestExtension)

- (BOOL)locationIsValid:(CLLocation *)location;

@end
