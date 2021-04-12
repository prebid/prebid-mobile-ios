//
//  MPVASTConstant.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTConstant.h"

NSString * const kMPVASTErrorDomain = @"com.mopub.VASTError";

// The minimum skip interval means that videos that are 16.0 seconds in length
// are allowed to be skipped. The official MoPub documentation says the the minimum
// skip length is 15 seconds, but that is inclusive of 15.1 seconds and 15.7 seconds.
// Thus we need to use a rounded up number.
NSTimeInterval const kVASTMinimumDurationOfSkippableVideo = 16; // seconds

NSTimeInterval const kVASTVideoOffsetToShowSkipButtonForSkippableVideo = 5;
NSTimeInterval const kVASTDefaultVideoOffsetToShowSkipButtonForRewardedVideo = 30;

NSString * const kVASTDefaultCallToActionButtonTitle = @"Learn More";
NSString * const kVASTMoPubCTATextKey = @"MoPubCtaText";
NSString * const kVASTAdTextKey = @"text";
