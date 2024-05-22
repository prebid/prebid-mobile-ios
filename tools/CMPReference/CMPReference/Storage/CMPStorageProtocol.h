//
//  CMPStorageProtocol.h
//  CMPConsentTool
//




#import <Foundation/Foundation.h>

@protocol CMPStorageProtocol
@required

/**
 The consent string passed as a websafe base64-encoded string.
 */
@property (nonatomic, retain) NSString *consentString;

/**
 subjectToGDPR value indicates
 nil value: unset subject to GDPR.
 @"0" value:  not subject to GDPR
 @1"value: subject to GDPR,
 */
@property (nonatomic, assign) NSString* subjectToGDPR;


/**
 Boolean that indicates if a CMP implementing the iAB specification is present in the application
 */
@property (nonatomic, assign) BOOL cmpPresent;



/**
 The CMP URL indicates Web page for consent details.
 */
@property (nonatomic, retain) NSString *cmpURL;


@end
