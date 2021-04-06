//
//  OXMVastAdsBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastAdsBuilder.h"

#import "OXMError.h"
#import "OXMLog.h"
#import "OXMAdDetails.h"
#import "OXMConstants.h"
#import "OXMVastParser.h"
#import "OXMVastInlineAd.h"
#import "OXMVastResponse.h"
#import "OXMVastRequester.h"
#import "OXMVastWrapperAd.h"
#import "OXMURLComponents.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMServerResponse.h"
#import "NSException+OxmExtensions.h"
#import "OXMVastCreativeLinear.h"
#import "OXMMacros.h"

typedef void(^OXMVastAdsBuilderWrapperCompletionBlock)(NSError *);

#pragma mark - Private Extension

@interface OXMVastAdsBuilder()

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong) id<OXMServerConnectionProtocol> serverConnection;
@property (nonatomic, assign) NSInteger requestsPending;
@property (nonatomic, assign) NSInteger maximumWrapperDepth;     // Per VAST 4.0 spec section 2.3.4.1
@property (nonatomic, strong, nullable) OXMVastResponse *rootResponse;

@end

#pragma mark - Implementation

@implementation OXMVastAdsBuilder

#pragma mark - Initialization

-(instancetype)initWithConnection:(id<OXMServerConnectionProtocol>)serverConnection {
    self = [super init];
    if (self) {
        OXMAssert(serverConnection);
        
        self.requestsPending = 0;
        self.maximumWrapperDepth = 5;
        self.serverConnection = serverConnection;
        self.dispatchQueue = dispatch_queue_create("OXMVastLoaderQueue", NULL);
    }
    return self;
}

#pragma mark - Public

- (void)buildAds:(nonnull NSData *)data completion:(OXMVastAdsBuilderCompletionBlock)completionBlock {
    @weakify(self);
    [self buildAds:data wrapperAd:nil completion:^(NSError *error){
        @strongify(self);
        
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        NSArray<OXMVastAbstractAd *> *ads = [self extractAdsWithError:&error];
        completionBlock(ads, error);
    }];
}

- (BOOL)checkHasNoAdsAndFireURIs:(OXMVastResponse *)vastResponse {
    
    BOOL firedNoAdsURI = false;
    
    // To check no ads responses, we find any response that had an Ad/Inline element that had zero creatives.
    // Then we walk backward from that response to any preceding wrapper responses that have an errorURI provided.
    
    if (vastResponse.vastAbstractAds.count == 0) {
        
        //If we have no ads, fire noAdsResponseURI on every wrapper up the chain.
        //First check response itself. then loop up
        
        OXMVastResponse *parent = vastResponse;
        while (parent) {
            
            //TODO: noAdsResponseURI is actually a template with an error code that must be plugged in.
            //Address this in https://jira.corp.openx.com/browse/MOBILE-3613
            
            if (parent.noAdsResponseURI) {
                [self.serverConnection fireAndForget: parent.noAdsResponseURI];
            }
            
            //Avoid infinite loop
            if (parent.parentResponse == parent) {
                break;
            }
            
            parent = parent.parentResponse;
        }
        firedNoAdsURI = true;
    }
    else {
        
        for (OXMVastAbstractAd *ad in vastResponse.vastAbstractAds) {
            
            //If the Ad is a wrapper
            if ([ad isKindOfClass: [OXMVastWrapperAd class]]) {
                OXMVastWrapperAd *unwrappedVASTWrapper = (OXMVastWrapperAd *)ad;
                
                //And it has a response
                if (unwrappedVASTWrapper.vastResponse) {
                    OXMVastResponse *unwrappedVastResponse = unwrappedVASTWrapper.vastResponse;
                    firedNoAdsURI = firedNoAdsURI || [self checkHasNoAdsAndFireURIs:unwrappedVastResponse];
                }
                else {
                    OXMLogError(@"No vastResponse on Wrapper");
                }
            }
        }
    }
    
    return firedNoAdsURI;
}

#pragma mark - Private

- (void)buildAds:(nonnull NSData *)data wrapperAd:(OXMVastWrapperAd *)wrapperAd completion:(OXMVastAdsBuilderWrapperCompletionBlock)completionBlock {
    
    if (wrapperAd && (wrapperAd.depth > self.maximumWrapperDepth)) {
        NSError *error = [OXMError errorWithDescription:@"Wrapper limit reached, as defined by the video player. Too many Wrapper responses have been received with no InLine response." statusCode:OXAErrorCodeUndefined];
        completionBlock(error);
        return;
    }
    
    OXMVastParser *parser = [OXMVastParser new];
    OXMVastResponse *parsedResponse = [parser parseAdsResponse:data];
    if (!parsedResponse) {
        NSString *strVast = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *message = [NSString stringWithFormat:@"VAST Parsing failed. XML was:  %@", strVast];
        completionBlock([OXMError errorWithDescription:message statusCode:OXAErrorCodeUndefined]);
        return;
    }

    @weakify(self);
    [self handleResponse:parsedResponse forWrapperAd:wrapperAd completion:^(NSError *error) {
        @strongify(self);
        if (!self) {
            completionBlock([OXMError errorWithDescription:@"VAST error: the ads builder is failed" statusCode:OXAErrorCodeUndefined]);
            return;
        }
        
        if (error) {
            completionBlock(error);
            return;
        }
        
        if (wrapperAd) {
            dispatch_sync(self.dispatchQueue, ^{
                self.requestsPending -= 1;
            });

            completionBlock(nil);
        } else if (self.requestsPending == 0) {
            completionBlock(nil);
        }
    }];
}

- (void)requestAds:(NSString *)vastURL
      forWrapperAd:(OXMVastWrapperAd *)wrapperAd
        completion:(OXMVastAdsBuilderWrapperCompletionBlock)completion {
    
    @weakify(self);
    dispatch_sync(self.dispatchQueue, ^{
        @strongify(self);
        if (!self) {
            completion([OXMError errorWithDescription:@"VAST error: the ads builder is failed" statusCode:OXAErrorCodeUndefined]);
            return;
        }
        
        self.requestsPending += 1;
    });
    
    [self.serverConnection get:vastURL timeout:OXMTimeInterval.CONNECTION_TIMEOUT_DEFAULT callback:^(OXMServerResponse * _Nonnull serverResponse) {
        if (serverResponse.error) {
            completion(serverResponse.error);
            return;
        }
        
        if (serverResponse.statusCode != 200) {
            NSString *message = [NSString stringWithFormat:@"Server responded with status code %li", (long)serverResponse.statusCode];
            completion([OXMError errorWithDescription:message statusCode:serverResponse.statusCode]);
            return;
        }
        
        [self buildAds:serverResponse.rawData wrapperAd:wrapperAd completion:completion];
    }];
}

- (void)handleResponse:(OXMVastResponse *)response
          forWrapperAd:(OXMVastWrapperAd *)wrapperAd
            completion:(OXMVastAdsBuilderWrapperCompletionBlock)completionBlock {
    
    if (wrapperAd) {
        //Assign nextResponse and parentResponse
        wrapperAd.vastResponse = response;
        response.parentResponse = wrapperAd.ownerResponse;
        
        //If multiple ads are disabled, drop everything but the first ad with a sequence of 0.
        if (!wrapperAd.allowMultipleAds) {
            for (OXMVastAbstractAd *ad in response.vastAbstractAds) {
                if (ad.sequence == 0) {
                    response.vastAbstractAds = [NSMutableArray arrayWithObject:ad];
                    break;
                }
            }
        }
        
        //If the parent asked us not to follow wrappers, remove any wrappers we find in the response.
        if (!wrapperAd.followAdditionalWrappers) {
            NSMutableArray *filtered = [NSMutableArray array];
            for (id obj in response.vastAbstractAds) {
                if (![obj isKindOfClass:[OXMVastWrapperAd class]]) {
                    [filtered addObject:obj];
                }
            }
            response.vastAbstractAds = filtered;
        }
        
        //Copy parent's allowMultipleAds setting to child wrappers
        for (id obj in response.vastAbstractAds) {
            if ([obj isKindOfClass:[OXMVastWrapperAd class]]) {
                OXMVastWrapperAd *wrapper = obj;
                wrapper.allowMultipleAds = wrapperAd.allowMultipleAds;
            }
        }
    }
    else {
        // If parentWrapper is nil, this is the root response.
        self.rootResponse = response;
    }
    
    //If we're not at the max depth then add a request for each wrapper.
    BOOL hasWrappers = NO;
    for (id obj in response.vastAbstractAds) {
        if ([obj isKindOfClass:[OXMVastWrapperAd class]]) {
            hasWrappers = YES;

            OXMVastWrapperAd *responseWrapperAd = obj;
            responseWrapperAd.depth = wrapperAd.depth + 1;
            
            [self requestAds:responseWrapperAd.vastURI forWrapperAd:responseWrapperAd completion:completionBlock];
        }
    }
    
    if (!hasWrappers) {
        completionBlock(nil);
    }
}

-(BOOL)hasValidMedia:(NSArray *)ads {
    for (OXMVastInlineAd *ad in ads) {
        for (OXMVastCreativeAbstract *creative in ad.creatives) {
            if ([creative isKindOfClass:[OXMVastCreativeLinear class]]) {
                OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*) creative;
                if ([oxmVastCreativeLinear bestMediaFile]) {
                    return true;
                }
            }
        }
    }
    return false;
}

- (NSArray<OXMVastAbstractAd *> *)extractAdsWithError:(NSError *__autoreleasing  _Nullable *)error {
    if (!self.rootResponse) {
        [OXMError createError:error description:@"No Root Response" statusCode:OXAErrorCodeFileNotFound];
        return nil;
    }
    
    // check for ads & media and fire appropriate URIs
    if ([self checkHasNoAdsAndFireURIs: self.rootResponse]) {
        [OXMError createError:error description:@"One or more responses had no ads" statusCode:OXAErrorCodeGeneralLinear];
        return nil;
    }
    
    NSError *flatterError;
    NSArray *ads = [self.rootResponse flattenResponseAndReturnError:&flatterError];
    if (flatterError) {
        if(error != nil) {
            *error = [flatterError copy];
        }
        return nil;
    }
    
    if (![self hasValidMedia:ads]) {
        [OXMError createError:error description:@"No Valid Media" statusCode:OXAErrorCodeFileNotFound];
        return nil;
    }
    
    return ads;
}

@end
