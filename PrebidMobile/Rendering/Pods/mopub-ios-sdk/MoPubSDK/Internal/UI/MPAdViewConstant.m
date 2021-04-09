//
//  MPAdViewConstant.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdViewConstant.h"

/**
 Per MRAID spec https://www.iab.com/wp-content/uploads/2015/08/IAB_MRAID_v2_FINAL.pdf, page 31, the
 close event region should be 50x50 expandable and interstitial ads. On page 34, the 50x50 size applies
 to resized ads as well.
 */
const CGSize kMPAdViewCloseButtonSize = {.width = 50, .height = 50};

const NSTimeInterval kDefaultRewardCountdownTimerIntervalInSeconds = 30;
