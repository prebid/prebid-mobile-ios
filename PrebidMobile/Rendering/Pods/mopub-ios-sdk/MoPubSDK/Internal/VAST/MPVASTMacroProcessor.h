//
//  MPVASTMacroProcessor.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVASTVerificationErrorReason.h"

extern const NSTimeInterval kMPVASTMacroProcessorUnknownTimeOffset;

@interface MPVASTMacroProcessor : NSObject

+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL errorCode:(NSString *)errorCode;
+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL errorCode:(NSString *)errorCode videoTimeOffset:(NSTimeInterval)timeOffset videoAssetURL:(NSURL *)videoAssetURL;
+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL verificationErrorReason:(MPVASTVerificationErrorReason)reason;

@end
