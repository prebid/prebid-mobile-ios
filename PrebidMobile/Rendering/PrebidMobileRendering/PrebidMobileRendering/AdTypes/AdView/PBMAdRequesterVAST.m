//
//  PBMAdRequesterVAST.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMAdRequestResponseVAST.h"
#import "PBMAdRequesterVAST.h"
#import "PBMConstants.h"
#import "PBMError.h"
#import "PBMMacros.h"
#import "PBMPathBuilder.h"
#import "PBMSDKConfiguration.h"
#import "PBMServerResponse.h"
#import "PBMURLComponents.h"
#import "PBMVastAdsBuilder.h"
#import "PBMVastRequester.h"

#pragma mark - Internal Interface

@interface PBMAdRequesterVAST ()

@property (nonatomic, strong) PBMVastAdsBuilder *adsBuilder;

@end

#pragma mark - Implementation

@implementation PBMAdRequesterVAST

#pragma mark - PBMAdRequester

- (instancetype) initWithServerConnection: (id<PBMServerConnectionProtocol>) serverConnection
                             adConfiguration: (PBMAdConfiguration*) adConfiguration  {
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
    [PBMVastRequester loadVastURL:url connection:self.serverConnection completion:^(PBMServerResponse * _Nullable serverResponse, NSError * _Nullable error) {
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
        PBMLogError(@"Loading of VAST is failed. Ads Builder is not intended to be re-used.");
        return;
    }
    
    self.adsBuilder = [[PBMVastAdsBuilder alloc] initWithConnection:self.serverConnection];
    @weakify(self);
    [self.adsBuilder buildAds:rawVASTData completion:^(NSArray<PBMVastAbstractAd *> *ads, NSError *error) {
        @strongify(self);
        
        if (error) {
            [self.adLoadManager requestCompletedFailure:error];
            return;
        }
        
        PBMAdRequestResponseVAST *adRequestResponseVast = [[PBMAdRequestResponseVAST alloc] init];
        adRequestResponseVast.ads = ads;
        [self.adLoadManager requestCompletedSuccess:adRequestResponseVast];
        
        self.adsBuilder = nil;
    }];
}

@end
