//
//  OXMUserConsentResolver.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXMUserConsentDataManager;

NS_ASSUME_NONNULL_BEGIN

@interface OXMUserConsentResolver : NSObject

@property (nonatomic, nullable, readonly, getter=isSubjectToGDPR) NSNumber *subjectToGDPR;
@property (nonatomic, nullable, readonly) NSString *gdprConsentString;

- (instancetype)initWithConsentDataManager:(OXMUserConsentDataManager *)consentDataManager;

@end

NS_ASSUME_NONNULL_END
