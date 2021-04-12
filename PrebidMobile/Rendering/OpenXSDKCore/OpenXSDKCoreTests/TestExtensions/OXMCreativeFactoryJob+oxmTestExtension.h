//
//  OXMCreativeFactoryJob+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMCreativeFactoryJob.h"

@interface OXMCreativeFactoryJob ()

- (void)attemptVASTCreative;
- (void)successWithCreative:(OXMAbstractCreative *)creative;
- (void)failWithError:(NSError *)error;
- (void)startJobWithTimeInterval:(NSTimeInterval)timeInterval;

@end
