//
//  OXMCreativeFactoryJob+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMCreativeFactoryJob.h"

@interface PBMCreativeFactoryJob ()

- (void)attemptVASTCreative;
- (void)successWithCreative:(PBMAbstractCreative *)creative;
- (void)failWithError:(NSError *)error;
- (void)startJobWithTimeInterval:(NSTimeInterval)timeInterval;

@end
