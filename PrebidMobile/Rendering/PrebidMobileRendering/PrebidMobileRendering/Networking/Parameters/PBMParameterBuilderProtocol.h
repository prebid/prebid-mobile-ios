//
//  PBMParameterBuilderProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@class PBMORTBBidRequest;

@protocol PBMParameterBuilder

- (void)buildBidRequest:(nonnull PBMORTBBidRequest *)bidRequest;

@end
