/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMAdRequestResponseVAST.h"
#import "PBMAdRequesterVAST.h"
#import "PBMConstants.h"
#import "PBMError.h"
#import "PBMMacros.h"
#import "PBMURLComponents.h"
#import "PBMVastAdsBuilder.h"
#import "PBMVastRequester.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Internal Interface

@interface PBMAdRequesterVAST ()

@property (nonatomic, strong) PBMVastAdsBuilder *adsBuilder;

@end

#pragma mark - Implementation

@implementation PBMAdRequesterVAST

#pragma mark - PBMAdRequester

- (instancetype) initWithServerConnection: (id<PrebidServerConnectionProtocol>) serverConnection
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
    [PBMVastRequester loadVastURL:url connection:self.serverConnection completion:^(PrebidServerResponse * _Nullable serverResponse, NSError * _Nullable error) {
        @strongify(self);
        
        if (!self) {
            PBMLogError(@"PBMAdRequesterVAST is nil");
            return;
        }
        
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
        
        if (!self) {
            PBMLogError(@"PBMAdRequesterVAST is nil");
            return;
        }
        
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
