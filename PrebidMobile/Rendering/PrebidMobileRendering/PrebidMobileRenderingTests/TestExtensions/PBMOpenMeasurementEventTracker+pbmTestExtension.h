//
//  OXMOpenMeasurementEventTracker+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@import OMSDK_Prebidorg;

@interface PBMOpenMeasurementEventTracker ()

@property (nonatomic, strong) OMIDPrebidorgAdEvents *adEvents;
@property (nonatomic, strong) OMIDPrebidorgMediaEvents *mediaEvents;
@property (nonatomic, strong) OMIDPrebidorgAdSession *session;

- (void)trackImpression;

@end
