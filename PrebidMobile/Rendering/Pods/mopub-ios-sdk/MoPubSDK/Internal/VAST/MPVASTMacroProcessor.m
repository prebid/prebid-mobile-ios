//
//  MPVASTMacroProcessor.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTMacroProcessor.h"
#import "MPGlobal.h"
#import "MPVASTStringUtilities.h"
#import "NSString+MPAdditions.h"

const NSTimeInterval kMPVASTMacroProcessorUnknownTimeOffset = -1;
const NSInteger kMPVASTMacroProcessorUnknownVerificationErrorReason = 0;

@implementation MPVASTMacroProcessor

#pragma mark - Public

+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL errorCode:(NSString *)errorCode
{
    return [self macroExpandedURLForURL:URL
                              errorCode:errorCode
                        videoTimeOffset:kMPVASTMacroProcessorUnknownTimeOffset
                          videoAssetURL:nil
                verificationErrorReason:kMPVASTMacroProcessorUnknownVerificationErrorReason];
}

+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL errorCode:(NSString *)errorCode videoTimeOffset:(NSTimeInterval)timeOffset videoAssetURL:(NSURL *)assetURL
{
    return [self macroExpandedURLForURL:URL
                              errorCode:errorCode
                        videoTimeOffset:timeOffset
                          videoAssetURL:assetURL
                verificationErrorReason:kMPVASTMacroProcessorUnknownVerificationErrorReason];
}

+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL verificationErrorReason:(MPVASTVerificationErrorReason)reason
{
    return [self macroExpandedURLForURL:URL
                              errorCode:nil
                        videoTimeOffset:kMPVASTMacroProcessorUnknownTimeOffset
                          videoAssetURL:nil
                verificationErrorReason:reason];
}

#pragma mark - Private

// Handles all macro replacement
+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL
                        errorCode:(NSString *)errorCode
                  videoTimeOffset:(NSTimeInterval)timeOffset
                    videoAssetURL:(NSURL *)assetURL
          verificationErrorReason:(MPVASTVerificationErrorReason)verificationErrorReason
{
    NSMutableString *URLString = [[URL absoluteString] mutableCopy];

    NSString *trimmedErrorCode = [errorCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedErrorCode length]) {
        [URLString replaceOccurrencesOfString:@"[ERRORCODE]" withString:errorCode options:0 range:NSMakeRange(0, [URLString length])];
        [URLString replaceOccurrencesOfString:@"%5BERRORCODE%5D" withString:errorCode options:0 range:NSMakeRange(0, [URLString length])];
    }

    if (timeOffset >= 0) {
        NSString *timeOffsetString = [MPVASTStringUtilities durationStringFromTimeInterval:timeOffset];
        [URLString replaceOccurrencesOfString:@"[CONTENTPLAYHEAD]" withString:timeOffsetString options:0 range:NSMakeRange(0, [URLString length])];
        [URLString replaceOccurrencesOfString:@"%5BCONTENTPLAYHEAD%5D" withString:timeOffsetString options:0 range:NSMakeRange(0, [URLString length])];
    }

    if (assetURL) {
        NSString *encodedAssetURLString = [[assetURL absoluteString] mp_URLEncodedString];
        [URLString replaceOccurrencesOfString:@"[ASSETURI]" withString:encodedAssetURLString options:0 range:NSMakeRange(0, [URLString length])];
        [URLString replaceOccurrencesOfString:@"%5BASSETURI%5D" withString:encodedAssetURLString options:0 range:NSMakeRange(0, [URLString length])];
    }

    NSString *cachebuster = [NSString stringWithFormat:@"%u", arc4random() % 90000000 + 10000000];
    [URLString replaceOccurrencesOfString:@"[CACHEBUSTING]" withString:cachebuster options:0 range:NSMakeRange(0, [URLString length])];
    [URLString replaceOccurrencesOfString:@"%5BCACHEBUSTING%5D" withString:cachebuster options:0 range:NSMakeRange(0, [URLString length])];

    if (verificationErrorReason >= MPVASTVerificationErrorReasonResourceRejected &&
        verificationErrorReason <= MPVASTVerificationErrorReasonResourceLoadError) {
        NSString *encodedErrorReason = [NSString stringWithFormat:@"%ld", (long)verificationErrorReason];
        [URLString replaceOccurrencesOfString:@"[REASON]" withString:encodedErrorReason options:0 range:NSMakeRange(0, [URLString length])];
        [URLString replaceOccurrencesOfString:@"%5BREASON%5D" withString:encodedErrorReason options:0 range:NSMakeRange(0, [URLString length])];
    }

    return [NSURL URLWithString:URLString];
}

@end
