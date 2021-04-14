//
//  OXMParameterBuilderProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@class OXMORTBBidRequest;

@protocol OXMParameterBuilder

- (void)buildBidRequest:(nonnull OXMORTBBidRequest *)bidRequest;

@end
