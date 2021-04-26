//
//  PBMVideoVerificationParameters.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMVastTrackingEvents;

@interface PBMVideoVerificationResource : NSObject

@property (nonatomic, strong, nullable) NSString *url;
@property (nonatomic, strong, nullable) NSString *vendorKey;
@property (nonatomic, strong, nullable) NSString *params;
@property (nonatomic, strong, nullable) NSString *apiFramework;

@property (nonatomic, strong, nullable) PBMVastTrackingEvents *trackingEvents;

@end

@interface PBMVideoVerificationParameters : NSObject

@property (nonatomic, strong, nonnull) NSMutableArray<PBMVideoVerificationResource *> *verificationResources;
@property (nonatomic, assign) BOOL autoPlay;

- (nonnull instancetype)init;

@end
