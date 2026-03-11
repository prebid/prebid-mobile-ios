#import "NativoBidRequester.h"

#import "PBMBidResponseTransformer.h"
#import "PBMPrebidParameterBuilder.h"
#import "PBMParameterBuilderService.h"
#import "NativoParameterBuilder.h"
#import "Log+Extensions.h"
#import "SwiftImport.h"
#import "PBMMacros.h"

@interface NativoBidRequester () <PBMBidRequester>

@property (nonatomic, strong, nonnull, readonly) id<PrebidServerConnectionProtocol> connection;
@property (nonatomic, strong, nonnull, readonly) Prebid *sdkConfiguration;
@property (nonatomic, strong, nonnull, readonly) Targeting *targeting;
@property (nonatomic, strong, nonnull, readonly) AdUnitConfig *adUnitConfiguration;

@property (nonatomic, copy, nullable) void (^completion)(BidResponse *, NSError *);

@end

@implementation NativoBidRequester

- (instancetype)initWithConnection:(id<PrebidServerConnectionProtocol>)connection
                  sdkConfiguration:(Prebid *)sdkConfiguration
                         targeting:(Targeting *)targeting
               adUnitConfiguration:(AdUnitConfig *)adUnitConfiguration {
    if (!(self = [super init])) {
        return nil;
    }
    _connection = connection;
    _sdkConfiguration = sdkConfiguration;
    _targeting = targeting;
    _adUnitConfiguration = adUnitConfiguration;
    return self;
}

- (void)requestBidsWithCompletion:(void (^)(BidResponse * _Nullable, NSError * _Nullable))completion {
    if (self.completion) {
        completion(nil, [PBMError requestInProgress]);
        return;
    }
    self.completion = completion ?: ^(BidResponse *r, NSError *e) {};

    NSString * const requestString = [self buildORTBRequestString];
    if (requestString.length == 0) {
        void (^ const done)(BidResponse *, NSError *) = self.completion;
        self.completion = nil;
        done(nil, [PBMError errorWithDescription:@"Failed to build ORTB request"]);
        return;
    }

    NSData *rtbRequestData = [requestString dataUsingEncoding:NSUTF8StringEncoding];

    const NSInteger rawTimeoutMS = self.sdkConfiguration.timeoutMillis;
    NSNumber * const dynamicTimeout = self.sdkConfiguration.timeoutMillisDynamic;
    const NSTimeInterval postTimeout = (dynamicTimeout ? dynamicTimeout.doubleValue : (rawTimeoutMS / 1000.0));

    // Fixed Nativo endpoint
    NSString * const nativoURL = @"http://exchange.postrelease.com/esi.json?ntv_epid=7&ntv_tm=tout";

    @weakify(self);
    [self.connection post:nativoURL
                     data:rtbRequestData
                  timeout:postTimeout
                 callback:^(PrebidServerResponse * _Nonnull serverResponse) {
        @strongify(self);
        if (!self) { return; }

        void (^ const done)(BidResponse *, NSError *) = self.completion;
        self.completion = nil;

        if (serverResponse.statusCode == 204) {
            done(nil, [PBMError blankResponse]);
            return;
        }

        if (serverResponse.error) {
            done(nil, serverResponse.error);
            return;
        }

        NSError *transformError = nil;
        NativoBidResponse * const bidResponse = [[NativoBidResponse alloc] initWithJsonDictionary:serverResponse.jsonDict];
        done(bidResponse, transformError);
    }];
}

- (NSString *)buildORTBRequestString {
    PBMPrebidParameterBuilder * const prebidParamsBuilder =
    [[PBMPrebidParameterBuilder alloc] initWithAdConfiguration:self.adUnitConfiguration
                                              sdkConfiguration:self.sdkConfiguration
                                                     targeting:self.targeting
                                              userAgentService:self.connection.userAgentService];
    
    // this will add tagid and any other needed params for Nativo
    NativoParameterBuilder * nativoParamsBuilder = [[NativoParameterBuilder alloc] initWithAdConfiguration:self.adUnitConfiguration];

    NSDictionary<NSString *, NSString *> * const params =
    [PBMParameterBuilderService buildParamsDictWithAdConfiguration:self.adUnitConfiguration.adConfiguration
                                           extraParameterBuilders:@[prebidParamsBuilder, nativoParamsBuilder]];

    return params[@"openrtb"] ?: @"";
}

@end
