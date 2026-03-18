#import <Foundation/Foundation.h>

@class AdUnitConfig;
@class BidResponse;
@class Prebid;
@class Targeting;
@protocol PrebidServerConnectionProtocol;
@protocol PBMBidRequesterProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface NativoBidRequester : NSObject <PBMBidRequesterProtocol>

- (instancetype)initWithConnection:(id<PrebidServerConnectionProtocol>)connection
                  sdkConfiguration:(Prebid *)sdkConfiguration
                         targeting:(Targeting *)targeting
               adUnitConfiguration:(AdUnitConfig *)adUnitConfiguration NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
