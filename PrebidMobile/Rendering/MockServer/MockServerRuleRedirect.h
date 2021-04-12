//
//  MockServerRuleRedirect.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "MockServerRule.h"

@interface MockServerRuleRedirect : MockServerRule

@property (nullable) NSURLRequest* redirectRequest;

@end
