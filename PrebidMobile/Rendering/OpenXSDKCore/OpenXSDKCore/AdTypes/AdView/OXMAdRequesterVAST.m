//
//  OXMAdRequesterVAST.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdRequestResponseVAST.h"
#import "OXMAdRequesterVAST.h"
#import "OXMConstants.h"
#import "OXMError.h"
#import "OXMMacros.h"
#import "OXMPathBuilder.h"
#import "OXASDKConfiguration.h"
#import "OXMServerResponse.h"
#import "OXMURLComponents.h"
#import "OXMVastAdsBuilder.h"
#import "OXMVastRequester.h"

#pragma mark - Internal Interface

@interface OXMAdRequesterVAST ()

@property (nonatomic, strong) OXMVastAdsBuilder *adsBuilder;

@end

#pragma mark - Implementation

@implementation OXMAdRequesterVAST

#pragma mark - OXMAdRequester

- (instancetype) initWithServerConnection: (id<OXMServerConnectionProtocol>) serverConnection
                             adConfiguration: (OXMAdConfiguration*) adConfiguration  {
    self = [super init];
    if (self) {
        self.serverConnection = serverConnection;
        self.adConfiguration = adConfiguration;
    }
    
    return self;
}

#pragma mark - Internal Methods

- (void)loadVASTURL:(NSString *)url {
    @weakify(self);
    [OXMVastRequester loadVastURL:url connection:self.serverConnection completion:^(OXMServerResponse * _Nullable serverResponse, NSError * _Nullable error) {
        @strongify(self);
        
        if (error) {
            [self.adLoadManager requestCompletedFailure:error];
        } else {
            [self buildVastAdsArray:serverResponse.rawData];
        }
    }];
}

- (void)load {
    // TODO: REMOVE ME
}


- (void)buildVastAdsArray:(NSData *)rawVASTData {
    if (self.adsBuilder) {
        OXMLogError(@"Loading of VAST is failed. Ads Builder is not intended to be re-used.");
        return;
    }
    
    self.adsBuilder = [[OXMVastAdsBuilder alloc] initWithConnection:self.serverConnection];
    @weakify(self);
    [self.adsBuilder buildAds:rawVASTData completion:^(NSArray<OXMVastAbstractAd *> *ads, NSError *error) {
        @strongify(self);
        
        if (error) {
            [self.adLoadManager requestCompletedFailure:error];
            return;
        }
        
        OXMAdRequestResponseVAST *adRequestResponseVast = [[OXMAdRequestResponseVAST alloc] init];
        adRequestResponseVast.ads = ads;
        [self.adLoadManager requestCompletedSuccess:adRequestResponseVast];
        
        self.adsBuilder = nil;
    }];
}

@end
