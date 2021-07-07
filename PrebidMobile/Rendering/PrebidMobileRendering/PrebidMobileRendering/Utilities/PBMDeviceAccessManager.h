/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PBMConstants.h"
#import <EventKitUI/EventKitUI.h>

#pragma mark - PBMDeviceAccessManagerKeys

@interface PBMDeviceAccessManager : NSObject<UIAlertViewDelegate, EKEventEditViewDelegate>

@property (nonatomic, strong, readonly, nonnull) NSString *deviceMake;
@property (nonatomic, strong, readonly, nonnull) NSString *deviceModel;
@property (nonatomic, strong, readonly, nonnull) NSString *identifierForVendor;
@property (nonatomic, strong, readonly, nonnull) NSString *deviceOS;
@property (nonatomic, strong, readonly, nonnull) NSString *OSVersion;
@property (nonatomic, strong, readonly, nullable) NSString *platformString;
@property (nonatomic, strong, readonly, nullable) NSString *userLangaugeCode;

// Support for dependancy injection and unit testing.
@property (nonatomic, copy, nullable) void (^currentCompletion)(BOOL succeeded, NSString * _Nullable message);
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *defaultPlist;

- (nonnull NSString *)advertisingIdentifier;
- (BOOL)advertisingTrackingEnabled;
- (CGSize)screenSize;

- (NSUInteger)appTrackingTransparencyStatus;

- (nonnull instancetype)init NS_UNAVAILABLE;

// Default Init
- (nonnull instancetype)initWithRootViewController:(nullable UIViewController *)viewController;

// DI Init
- (nonnull instancetype)initWithRootViewController:(nullable UIViewController *)viewController
                                     plist:(nonnull NSDictionary<NSString *, id> *)plist
                                        eventStore:(nonnull EKEventStore*)store
                                            locale:(nonnull NSLocale *)locale;

- (void)createCalendarEventFromString:(nonnull NSString *)eventString completion:(void(^_Nonnull)(BOOL succeeded, NSString * _Nonnull message))completion NS_SWIFT_NAME(createCalendarEventFromString(_:completion:));
- (void)savePhotoWithUrlToAsset:(nonnull NSURL *)urlToAsset completion:(void(^_Nonnull)(BOOL succeeded, NSString * _Nonnull message))completion NS_SWIFT_NAME(savePhotoWithUrlToAsset(_:completion:));


// These methods are exposed for unit testing purposes.
+ (nullable EKRecurrenceRule *)createRecurrenceRuleWithDictionary:(nullable PBMJsonDictionary *)dict;
+ (nonnull NSArray<EKRecurrenceDayOfWeek *> *)recurrenceDayOfWeekArrayWithArray:(nonnull NSArray<NSNumber *> *)array;

// Dependency injection so that we can use to test various error cases.
// plist is used to verify access to system services (i.e. calendar, photo library).

- (void)savePhotoWithUrlToAsset: (nonnull NSURL *)urlToAsset
                alertController: (nonnull UIAlertController *) alertVC
             rootViewController: (nullable UIViewController*) rootVC
                            yes: (nullable UIAlertAction *) yesAction
                             no: (nullable UIAlertAction *) noAction
                     completion: (void(^_Nullable)(BOOL succeeded, NSString * _Nullable message))completion
NS_SWIFT_NAME(savePhoto(url:alertController:rootViewController:yes:no:completion:));

- (void) savePhoto: (nonnull NSURL *)urlToAsset completion: (void(^_Nullable)(BOOL succeeded, NSString * _Nullable message)) completion  NS_SWIFT_NAME(savePhoto(url:completion:));

- (void)internalAddEvent:(nonnull NSString *)eventString
              completion:(void(^_Nonnull)(BOOL succeeded, NSString * _Nonnull message))completion;

@end
