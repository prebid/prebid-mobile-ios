//
//  CMPConsentToolViewController.h
//  CMPConsentTool
//





#import <UIKit/UIKit.h>
#import "CMPSettings.h"

@class CMPConsentViewController;
@protocol CMPConsentViewControllerDelegate <NSObject>
- (void)consentToolViewController:(CMPConsentViewController *)consentToolViewController didReceiveConsentString:(NSString*)consentString;
- (void)consentToolViewController:(CMPConsentViewController *)consentToolViewController didReceiveURL:(NSURL *)url;
@end

@interface CMPConsentViewController : UIViewController

/**
 NSURL that is used to create and load the request into the WKWebView – it is the request for the consent webpage. This property is mandatory.
 */

/**
 Object that provides the API for storing and retrieving GDPR-related information
 */
@property (nonatomic, retain) CMPSettings *cmpSettings;

/**
 Optional delegate to receive callbacks from the CMP web tool
 */
@property (nonatomic, weak) id<CMPConsentViewControllerDelegate> delegate;
@end
