//
//  OMIDSDK.h
//  AppVerificationLibrary
//
//  Created by Daria on 05/06/2017.
//

#import <Foundation/Foundation.h>

/**
 *  This application level class will be called by all integration partners to ensure OM SDK has been activated before calling any other API methods.
 * Any attempt to use other API methods prior to activation will result in an error.
 *
 * Note that OM SDK may only be used on the main UI thread.
 * Make sure you are on the main thread when you initialize the SDK, create its
 * objects, and invoke its methods.
 */
@interface OMIDMopubSDK : NSObject

/**
 *  The current semantic version of the integrated OMID library.
 */
+ (nonnull NSString *)versionString;

/**
 *  Shared OMIDSDK instance.
 */
@property(class, readonly, nonnull) OMIDMopubSDK *sharedInstance
NS_SWIFT_NAME(shared);

/**
 *  A Boolean value indicating whether the OMID library has been activated.
 *
 *  The value of this property is YES if the OMID library has already been activated. Allows the integration partner to check that they are compatible with the running OMID library version.
 */
@property(atomic, readonly, getter = isActive) BOOL active;

/**
 *  Enables the integration partner to activate OMID.
 */
- (BOOL)activate;

@end

