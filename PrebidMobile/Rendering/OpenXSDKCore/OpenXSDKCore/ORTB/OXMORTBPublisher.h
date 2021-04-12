//
//  OXMORTBPublisher.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.15: Publisher

//This object describes the publisher of the media in which the ad will be displayed. The publisher is
//typically the seller in an OpenRTB transaction.
@interface OXMORTBPublisher : OXMORTBAbstract

//Exchange-specific publisher ID.
@property (nonatomic, copy, nullable) NSString *publisherID;

//Publisher name (may be aliased at the publisher’s request)
@property (nonatomic, copy, nullable) NSString *name;

//Array of IAB content categories that describe the publisher
@property (nonatomic, copy) NSArray<NSString *> *cat;

//Highest level domain of the publisher (e.g., “publisher.com”)
@property (nonatomic, copy, nullable) NSString *domain;

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext is not supported.

- (instancetype )init;

@end

NS_ASSUME_NONNULL_END
