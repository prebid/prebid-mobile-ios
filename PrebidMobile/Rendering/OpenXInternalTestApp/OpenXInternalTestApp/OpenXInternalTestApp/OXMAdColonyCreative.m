//
//  OXMAdColonyCreative.m
//  AdColonyAdapter
//
//  Copyright (c) 2018 OpenX. All rights reserved.
//

#import <AdColony/AdColony.h>

#import "OXMAdColonyCreative.h"

#pragma mark - Constants

static NSString * const OXMAdColonyAppIDKey     = @"app_id";
static NSString * const OXMAdColonyZoneIDKey    = @"zone_id";
static NSString * const OXMAdColonyZoneIDsKey   = @"zone_ids";

#pragma mark - Interface

@interface OXMAdColonyCreative()

@property (nonatomic, assign) AdColonyInterstitial *interstitialAd;
@property (nonatomic, assign) NSString *zoneID;

@end

#pragma mark - Implementation

@implementation OXMAdColonyCreative
- (nonnull instancetype)initWithCreativeModel:(nonnull OXMCreativeModel *)oxmCreativeModel
                                  transaction:(nonnull OXMTransaction *)transaction
                                 modalManager:(nonnull OXMModalManager *)modalManager
                             serverConnection:(nonnull OXMServerConnection *)serverConnection {

@implementation OXMAdColonyInterstitialCreative

- (nonnull instancetype)initWithCreativeModel:(nonnull OXMCreativeModel *)oxmCreativeModel transaction:(OXMTransaction *)transaction serverConnection:(nonnull OXMServerConnection *)serverConnection{
    self = [super initWithCreativeModel:oxmCreativeModel transaction:transaction serverConnection:serverConnection];
    if (self) {
        self.clickthroughVisible = NO;
        self.oxmCreativeModel.adConfiguration.forceMediatedInterstitial = YES;
    }
    
    return self;
}

#pragma mark - OXMAbstractCreative

- (void)setupView {
    [super setupView];
    
    if (!(self.oxmCreativeModel && self.oxmCreativeModel.adConfiguration)) {
        [self failResolution: [OXMError errorWithDescription:@"Creative model is empty"]];
        return;
    }
    
    NSString *appID = self.oxmCreativeModel.mediatedSDKparams[OXMAdColonyAppIDKey];
    NSString *zoneIDs = self.oxmCreativeModel.mediatedSDKparams[OXMAdColonyZoneIDsKey];
    self.zoneID = self.oxmCreativeModel.mediatedSDKparams[OXMAdColonyZoneIDKey];

    if (!(appID && self.zoneID)) {
        [self failResolution: [OXMError errorWithDescription:@"Requirements not met request the ad"]];
        return;
    }

    if (zoneIDs == nil) {
        zoneIDs = self.zoneID;
    }
    

    //Configure AdColony as soon as the app starts
    __weak __typeof(self)weakSelf = self;
    
    
    [AdColony configureWithAppID:appID zoneIDs:@[zoneIDs] options:nil completion:^(NSArray<AdColonyZone *> *zones) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        [strongSelf requestInterstitial:strongSelf.zoneID];
        
        //If the application has been inactive for a while, our ad might have expired so let's add a check for a nil ad object
        [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(onBecameActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }];
}


- (void)displayWithRootViewController:(UIViewController *)viewController {
    [self.interstitialAd showWithPresentingViewController:viewController];

    [super displayWithRootViewController:viewController];
}

#pragma mark - AdColony

- (void)requestInterstitial:(NSString *)zoneID {
    
    __weak __typeof(self)weakSelf = self;
    [AdColony requestInterstitialInZone:zoneID
                                options:nil
                                success:^(AdColonyInterstitial *ad) {
                                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                                    if (!strongSelf) {
                                        return;
                                    }
                                    
                                    ad.close = ^{
                                        OXMLogWhereAmI();
                                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                                        if (!strongSelf) {
                                            return;
                                        }
                                        
                                        strongSelf.interstitialAd = nil;
                                        [strongSelf.creativeViewDelegate creativeDidComplete:strongSelf];
                                        // Close the modal view
// How do we close the modal manager if there is none.
//                                        [strongSelf.modalManager modalViewControllerCloseButtonTapped];
                                        // Trigger the InterstitialDidClose notification.
                                        [strongSelf.creativeViewDelegate creativeInterstitialDidClose:strongSelf];
                                    };
                                    
                                    ad.expire = ^{
                                        OXMLogWhereAmI();
                                        OXMLogWhereAmI();
                                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                                        if (!strongSelf) {
                                            return;
                                        }
                                        
                                        strongSelf.interstitialAd = nil;
                                        [strongSelf requestInterstitial:zoneID];
                                    };
                                    
                                    ad.open = ^{
                                        OXMLogWhereAmI();
                                        [weakSelf.creativeViewDelegate creativeDidDisplay:weakSelf];
                                    };
                                    
                                    ad.leftApplication = ^ {
                                        OXMLogWhereAmI();
                                        [weakSelf.creativeViewDelegate creativeInterstitialDidLeaveApp:weakSelf];
                                    };
                                    
                                    ad.click = ^ {
                                        OXMLogWhereAmI();
                                        [weakSelf.creativeViewDelegate creativeWasClicked:weakSelf];
                                    };
                                    
                                    
                                    strongSelf.interstitialAd = ad;
                                    [strongSelf resolveSuccessfully];
                                }
                                failure:^(AdColonyAdRequestError *error) {
                                    NSString *message = [NSString stringWithFormat:@"OXMAdColonyCreative: Request failed with error: %@ and suggestion: %@", [error localizedDescription], [error localizedRecoverySuggestion]];
                                    [weakSelf failResolution:[OXMError errorWithDescription:message]];
                                }
     ];
}

#pragma mark - Internal

- (void)onBecameActive {
    if (!self.interstitialAd && self.zoneID) {
        [self requestInterstitial: self.zoneID];
    }
}

@end
