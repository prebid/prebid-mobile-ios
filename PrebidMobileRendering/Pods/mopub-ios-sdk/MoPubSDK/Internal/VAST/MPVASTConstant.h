//
//  MPVASTConstant.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

/**
 See documentation at https://developers.mopub.com/dsps/ad-formats/video/
 */

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kMPVASTErrorDomain;

extern NSTimeInterval const kVASTMinimumDurationOfSkippableVideo;
extern NSTimeInterval const kVASTVideoOffsetToShowSkipButtonForSkippableVideo;
extern NSTimeInterval const kVASTDefaultVideoOffsetToShowSkipButtonForRewardedVideo;

extern NSString * const kVASTDefaultCallToActionButtonTitle;
extern NSString * const kVASTMoPubCTATextKey;
extern NSString * const kVASTAdTextKey;

NS_ASSUME_NONNULL_END
