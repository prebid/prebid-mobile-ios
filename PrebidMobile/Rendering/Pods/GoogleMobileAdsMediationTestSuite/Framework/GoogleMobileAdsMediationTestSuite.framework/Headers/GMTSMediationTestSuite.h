//  Copyright © 2017 Google. All rights reserved.

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

/// Protocol to be notified of Mediation Test Suite events such as when the test suite is dismissed.
@protocol GMTSMediationTestSuiteDelegate <NSObject>

/// Called when the test suite is dismissed.
- (void)mediationTestSuiteWasDismissed;

@end

/// The facade class representing the entry point to the mediation test suite.
@interface GoogleMobileAdsMediationTestSuite : NSObject

/// Present the mediation test suite using the AdMob application ID from your Info.plist.
///
/// \param controller the view controller to present on.
///
/// \param delegate an optional test suite delegate.
+ (void)presentOnViewController:(nonnull UIViewController *)controller
                       delegate:(nullable id<GMTSMediationTestSuiteDelegate>)delegate;

/// Present the mediation test suite.
///
/// \param appID Your AdMob application ID.
///
/// \param controller the view controller to present on.
///
/// \param delegate an optional test suite delegate.
+ (void)presentWithAppID:(nonnull NSString *)appID
        onViewController:(nonnull UIViewController *)controller
                delegate:(nullable id<GMTSMediationTestSuiteDelegate>)delegate
    GAD_DEPRECATED_MSG_ATTRIBUTE("Use presentOnViewController:delegate: instead.");

/// Set the base ad request on the test suite.
+ (void)setAdRequest:(nonnull GADRequest *)adRequest NS_SWIFT_NAME(setAdRequest(_:));

@end
