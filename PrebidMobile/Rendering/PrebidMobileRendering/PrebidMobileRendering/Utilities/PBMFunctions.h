//
//  PBMFunctions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface PBMFunctions : NSObject

+ (NSString *)sdkVersion;
+ (NSString *)omidVersion;
+ (NSDictionary<NSString *, NSString *> *)extractVideoAdParamsFromTheURLString:(NSString *)urlString forKeys:(NSArray *)keys;
+ (BOOL)canLoadVideoAdWithDomain:(NSString *)domain adUnitID:(nullable NSString *)adUnitID adUnitGroupID:(nullable NSString *)adUnitGroupID;
+ (void)checkCertificateChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;

//FIXME: move to private fucntions ??
#pragma mark - SDK Info

+ (nonnull NSBundle *)bundleForSDK;
+ (nullable NSString *)infoPlistValueFor:(nonnull NSString *)key
    NS_SWIFT_NAME(infoPlistValue(_:));

@end
NS_ASSUME_NONNULL_END
