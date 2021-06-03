//
//  PBMUserConsentResolver.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMUserConsentDataManager;

NS_ASSUME_NONNULL_BEGIN

@interface PBMUserConsentResolver : NSObject

@property (nonatomic, nullable, readonly, getter=isSubjectToGDPR) NSNumber *subjectToGDPR;
@property (nonatomic, nullable, readonly) NSString *gdprConsentString;
@property (nonatomic, assign, readonly) BOOL canAccessDeviceData;

- (instancetype)initWithConsentDataManager:(PBMUserConsentDataManager *)consentDataManager;

@end

NS_ASSUME_NONNULL_END
