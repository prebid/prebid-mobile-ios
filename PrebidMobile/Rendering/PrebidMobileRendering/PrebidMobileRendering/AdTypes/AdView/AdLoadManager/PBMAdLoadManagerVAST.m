//
//  PBMAdLoadManager.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMAdDetails.h"
#import "PBMAdLoadManagerVAST.h"
#import "PBMAdRequesterVAST.h"
#import "PBMCreativeModelCollectionMakerVAST.h"
#import "PBMMacros.h"
#import "PBMMacros.h"
#import "PBMAdDetails.h"
#import "PBMServerResponse.h"
#import "PBMTransaction.h"


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
                                          PBMLogError(@"PBMAdLoadManager is nil!");
                                          return;
                                      }
                                      
                                      [self makeCreativesWithCreativeModels:creativeModels];
                                  }
                                  failureCallback: ^(NSError *error) {
                                      @strongify(self);
                                      if (!self) {
                                          PBMLogError(@"PBMAdLoadManager is nil!");
                                          return;
                                      }
                                      
                                      [self.adLoadManagerDelegate loadManager:self failedToLoadTransaction:nil error:error];
                                  }];
}

@end
