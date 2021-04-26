//
//  OXMOpenMeasurementEventTracker+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@import OMSDK_Openx;

@interface PBMOpenMeasurementEventTracker ()

@property (nonatomic, strong) OMIDOpenxAdEvents *adEvents;
@property (nonatomic, strong) OMIDOpenxMediaEvents *mediaEvents;
@property (nonatomic, strong) OMIDOpenxAdSession *session;

- (void)trackImpression;

@end
