//
//  PBMDeviceAccessManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

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
