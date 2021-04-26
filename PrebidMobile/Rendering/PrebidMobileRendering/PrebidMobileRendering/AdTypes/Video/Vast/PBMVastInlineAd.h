//
//  PBMVastInlineAd.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastAbstractAd.h"
#import "PBMVideoVerificationParameters.h"

//See PBMVastAbstractAd for VAST structure details

@interface PBMVastInlineAd : PBMVastAbstractAd

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *advertiser;

@property (nonatomic, strong, nonnull) PBMVideoVerificationParameters *verificationParameters;


@end
