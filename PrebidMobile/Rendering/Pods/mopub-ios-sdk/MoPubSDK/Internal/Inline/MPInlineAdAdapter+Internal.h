//
//  MPInlineAdAdapter+Internal.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInlineAdAdapter.h"
#import "MPInlineAdAdapterWebSessionDelegate.h"

@interface MPInlineAdAdapter (Internal) <MPInlineAdAdapterWebSessionDelegate>

/**
 Track impressions for trackers that are included in the creative's markup.
 Extended class implements this method if necessary.
 Currently, only HTML and MRAID banners use trackers included in markup.
 Mediated networks track impressions via their own means.
 */
- (void)trackImpressionsIncludedInMarkup;

@end
