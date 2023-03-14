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

#import "PBMAdDetails.h"
#import "PBMAdLoadManagerVAST.h"
#import "PBMAdRequesterVAST.h"
#import "PBMCreativeModelCollectionMakerVAST.h"
#import "PBMMacros.h"
#import "PBMMacros.h"
#import "PBMAdDetails.h"
#import "PBMTransaction.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Internal Interface

@interface PBMAdLoadManagerVAST ()

@property (nonatomic, strong) PBMCreativeModelCollectionMakerVAST* creativeModelCollectionMaker;
@property (nonatomic, strong) PBMAdRequesterVAST *adRequester;

@end

#pragma mark - Implementation

@implementation PBMAdLoadManagerVAST

- (void)loadFromString:(NSString *)vastString {
    @weakify(self);
    dispatch_async(self.dispatchQueue, ^{
        @strongify(self);
        if (!self) {
            PBMLogError(@"PBMAdLoadManagerVast is nil!");
            return;
        }
        
        if ([self prepareForLoading]) {
            [self.adRequester buildVastAdsArray:[vastString dataUsingEncoding:NSUTF8StringEncoding]];
        }
    });
}

- (BOOL)prepareForLoading {
    if (self.adRequester) {
        PBMLogError(@"Previous load is in progress. Load() ignored.");
        return NO;
    }
    self.adRequester = [[PBMAdRequesterVAST alloc] initWithServerConnection:self.connection adConfiguration:self.adConfiguration];
    self.adRequester.adLoadManager = self;
    
    self.creativeModelCollectionMaker = [[PBMCreativeModelCollectionMakerVAST alloc] initWithServerConnection:self.connection adConfiguration:self.adConfiguration];
    return YES;
}

- (void)requestCompletedSuccess:(PBMAdRequestResponseVAST *)adRequestResponse {
    PBMLogWhereAmI();
    
    @weakify(self);
    [self.creativeModelCollectionMaker makeModels:adRequestResponse
                                  successCallback: ^(NSArray *creativeModels) {
                                      @strongify(self);
                                      if (!self) {
                                          PBMLogError(@"PBMAdLoadManagerVAST is nil!");
                                          return;
                                      }
                                      
                                      [self makeCreativesWithCreativeModels:creativeModels];
                                  }
                                  failureCallback: ^(NSError *error) {
                                      @strongify(self);
                                      if (!self) {
                                          PBMLogError(@"PBMAdLoadManagerVAST is nil!");
                                          return;
                                      }
                                      
                                      [self.adLoadManagerDelegate loadManager:self failedToLoadTransaction:nil error:error];
                                  }];
}

@end
