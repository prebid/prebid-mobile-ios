//
//  OXMVideoVerificationParameters.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXMVastTrackingEvents;

@interface OXMVideoVerificationResource : NSObject

@property (nonatomic, strong, nullable) NSString *url;
@property (nonatomic, strong, nullable) NSString *vendorKey;
@property (nonatomic, strong, nullable) NSString *params;
@property (nonatomic, strong, nullable) NSString *apiFramework;

@property (nonatomic, strong, nullable) OXMVastTrackingEvents *trackingEvents;

@end

@interface OXMVideoVerificationParameters : NSObject

@property (nonatomic, strong, nonnull) NSMutableArray<OXMVideoVerificationResource *> *verificationResources;
@property (nonatomic, assign) BOOL autoPlay;

- (nonnull instancetype)init;

@end
