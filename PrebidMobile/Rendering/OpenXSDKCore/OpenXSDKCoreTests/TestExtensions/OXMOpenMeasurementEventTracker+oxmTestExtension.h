//
//  OXMOpenMeasurementEventTracker+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMTransaction.h"

@import OMSDK_Openx;

@interface OXMOpenMeasurementEventTracker ()

@property (nonatomic, strong) OMIDOpenxAdEvents *adEvents;
@property (nonatomic, strong) OMIDOpenxMediaEvents *mediaEvents;
@property (nonatomic, strong) OMIDOpenxAdSession *session;

- (void)trackImpression;

@end
