//
//  OXMAdLoadManager.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdDetails.h"
#import "OXMAdLoadManagerVAST.h"
#import "OXMAdRequesterVAST.h"
#import "OXMCreativeModelCollectionMakerVAST.h"
#import "OXMMacros.h"
#import "OXASDKConfiguration.h"
#import "OXMMacros.h"
#import "OXMAdDetails.h"
#import "OXMServerResponse.h"
#import "OXMTransaction.h"


#pragma mark - Internal Interface

@interface OXMAdLoadManagerVAST ()

@property (nonatomic, strong) OXMCreativeModelCollectionMakerVAST* creativeModelCollectionMaker;
@property (nonatomic, strong) OXMAdRequesterVAST *adRequester;

@end

#pragma mark - Implementation

@implementation OXMAdLoadManagerVAST

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
        OXMLogError(@"Previous load is in progress. Load() ignored.");
        return NO;
    }
    self.adRequester = [[OXMAdRequesterVAST alloc] initWithServerConnection:self.connection adConfiguration:self.adConfiguration];
    self.adRequester.adLoadManager = self;
    
    self.creativeModelCollectionMaker = [[OXMCreativeModelCollectionMakerVAST alloc] initWithServerConnection:self.connection adConfiguration:self.adConfiguration];
    return YES;
}

- (void)requestCompletedSuccess:(OXMAdRequestResponseVAST *)adRequestResponse {
    OXMLogWhereAmI();
    
    @weakify(self);
    [self.creativeModelCollectionMaker makeModels:adRequestResponse
                                  successCallback: ^(NSArray *creativeModels) {
                                      @strongify(self);
                                      if (!self) {
                                          OXMLogError(@"OXMAdLoadManager is nil!");
                                          return;
                                      }
                                      
                                      [self makeCreativesWithCreativeModels:creativeModels];
                                  }
                                  failureCallback: ^(NSError *error) {
                                      @strongify(self);
                                      if (!self) {
                                          OXMLogError(@"OXMAdLoadManager is nil!");
                                          return;
                                      }
                                      
                                      [self.adLoadManagerDelegate loadManager:self failedToLoadTransaction:nil error:error];
                                  }];
}

@end
