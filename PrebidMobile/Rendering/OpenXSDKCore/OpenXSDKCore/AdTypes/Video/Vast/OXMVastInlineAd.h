//
//  OXMVastInlineAd.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastAbstractAd.h"
#import "OXMVideoVerificationParameters.h"

//See OXMVastAbstractAd for VAST structure details

@interface OXMVastInlineAd : OXMVastAbstractAd

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *advertiser;

@property (nonatomic, strong, nonnull) OXMVideoVerificationParameters *verificationParameters;


@end
