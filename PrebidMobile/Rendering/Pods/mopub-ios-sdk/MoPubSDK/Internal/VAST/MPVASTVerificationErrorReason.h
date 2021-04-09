//
//  MPVASTVerificationErrorReason.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

/**
 These values correspond to the [REASON] macro for the `verificationNotExecuted` VAST tracking event.
 */
typedef NS_ENUM(NSInteger, MPVASTVerificationErrorReason) {
    /**
     Verification resource rejected. The publisher does not
     recognize or allow code from the vendor in the parent
     <Verification>.
     */
    MPVASTVerificationErrorReasonResourceRejected = 1,

    /**
     Verification not supported. The API framework or language
     type of verification resources provided are not implemented
     or supported by the player/SDK.
     */
    MPVASTVerificationErrorReasonVerificationNotSupported = 2,

    /**
     Error during resource load. The player/SDK was not able to
     fetch the verification resource, or some error occurred that
     the player/SDK was able to detect. Examples of detectable
     errors: malformed resource URLs, 404 or other failed
     response codes, request time out. Examples of potentially
     undetectable errors: parsing or runtime errors in the JS
     resource.
     */
    MPVASTVerificationErrorReasonResourceLoadError = 3
};
