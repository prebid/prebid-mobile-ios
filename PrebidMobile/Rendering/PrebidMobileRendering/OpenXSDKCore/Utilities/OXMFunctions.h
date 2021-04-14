//
//  OXMFunctions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface OXMFunctions : NSObject

+ (NSString *)sdkVersion;
+ (NSString *)omidVersion;
+ (NSDictionary<NSString *, NSString *> *)extractVideoAdParamsFromTheURLString:(NSString *)urlString forKeys:(NSArray *)keys;
+ (BOOL)canLoadVideoAdWithDomain:(NSString *)domain adUnitID:(nullable NSString *)adUnitID adUnitGroupID:(nullable NSString *)adUnitGroupID;
+ (void)checkCertificateChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;

@end
NS_ASSUME_NONNULL_END
