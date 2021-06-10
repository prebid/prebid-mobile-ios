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

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/ATTrackingManager.h>

#import "PBMDeviceAccessManager.h"
#import "PBMDeviceAccessManagerKeys.h"
#import "PBMFunctions+Private.h"
#import "PBMDateFormatService.h"
#include <sys/sysctl.h>

#pragma mark - PBMAddEventViewController

static EKEventStore * eventStore = nil;

// This subclass of EKEventEditViewController exists only to allow it to retain the DeviceAccessManager...
// which needs to stick around to respond to the editeventcontroller
// once the EKEditViewController goes out of scope, it will stop retaining the DAM, letting it deinit
@interface PBMAddEventViewController : EKEventEditViewController

@property (nonatomic, strong, nullable) PBMDeviceAccessManager *deviceAccessManager;

@end

@implementation PBMAddEventViewController
@end

#pragma mark - UIViewController (PBMPrivate)

@implementation UIViewController (PBMPrivate)

// Adding rootVC for dependency injection.
- (void)showWithRootController:(UIViewController *)rootVC  {
    if (rootVC) {
        [self presentFromController:rootVC animated:YES completion:nil];
    }
}


- (void)presentFromController:(UIViewController *)controller animated:(BOOL)animated completion:(void (^)(void))completion {
    
    UINavigationController *navigationController = [controller isKindOfClass:[UINavigationController class]] ? (UINavigationController *)controller : nil;
    UITabBarController *tabBarController = [controller isKindOfClass:[UITabBarController class]] ? (UITabBarController *)controller : nil;
    
    if (navigationController && navigationController.visibleViewController) {
        [self presentFromController:navigationController.visibleViewController animated:animated completion:completion];
    } else if (tabBarController && tabBarController.selectedViewController) {
        [self presentFromController:tabBarController.selectedViewController animated:animated completion:completion];
    } else {
        [controller presentViewController:self animated:animated completion:completion];
    }
}

@end

#pragma mark - PBMDeviceAccessManager

@interface PBMDeviceAccessManager ()
@property (nonatomic, strong, readonly, nonnull) NSLocale *locale;
@property (nonatomic, weak, nullable) UIViewController *rootViewController;
@end

#pragma mark - Implementation

@implementation PBMDeviceAccessManager

#pragma mark - Properties

+ (nonnull EKEventStore *)eventStore {
    if (eventStore == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            eventStore = [EKEventStore new];
        });
    }
    return eventStore;
}

#pragma mark - Initialization

- (instancetype)initWithRootViewController:(UIViewController *)viewController {
    return [self initWithRootViewController:viewController
                                      plist:NSBundle.mainBundle.infoDictionary
                                 eventStore:PBMDeviceAccessManager.eventStore
                                     locale:NSLocale.autoupdatingCurrentLocale];
}

- (instancetype)initWithRootViewController:(UIViewController *)viewController
                                     plist:(NSDictionary<NSString *,id> *)plist
                                eventStore:(EKEventStore *)store
                                    locale:(NSLocale *)locale {
    self = [super init];
    if (self) {
        self.currentCompletion = nil;
        self.rootViewController = viewController;
        self.defaultPlist = plist;
        if (store) {
            eventStore = store;
        }
        
        _locale = (locale) ? locale : [NSLocale autoupdatingCurrentLocale];
    }
    return self;
}

#pragma mark - UIDevice

- (nonnull NSString *)deviceMake {
    return @"Apple";
}

- (nonnull NSString *)deviceModel {
    return [UIDevice currentDevice].model;
}

- (nonnull NSString *)identifierForVendor {
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

- (nonnull NSString *)deviceOS {
    return [UIDevice currentDevice].systemName;
}

- (nonnull NSString *)OSVersion {
    return [UIDevice currentDevice].systemVersion;
}

- (nullable NSString *)platformString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
}

- (nullable NSString *)userLangaugeCode {
    return [self.locale objectForKey:NSLocaleLanguageCode];
}

#pragma mark - IDFA

- (nonnull NSString *)advertisingIdentifier {
    return [ASIdentifierManager.sharedManager advertisingIdentifier].UUIDString;
}

- (BOOL)advertisingTrackingEnabled {
    return ASIdentifierManager.sharedManager.isAdvertisingTrackingEnabled;
}

- (NSUInteger)appTrackingTransparencyStatus {
    if (@available(iOS 14.0, *)) {
        return ATTrackingManager.trackingAuthorizationStatus;
    } else {
        return 0; //ATTrackingManagerAuthorizationStatusNotDetermined
    }
}

- (CGSize)screenSize {
    return [PBMFunctions deviceScreenSize];
}


#pragma mark- PhotoSave

- (void)savePhotoWithUrlToAsset:(nonnull NSURL *)urlToAsset
                     completion:(void(^)(BOOL, NSString *))completion {
    self.currentCompletion = completion;
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Save Image?"
                                                                     message:@"This ad is requesting permission to save an image to your photo album. Would you like to save this image?"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self savePhoto:urlToAsset completion:nil];
        });
        
        completion(YES, @"Save action");
    }];
    
    UIAlertAction * noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion(false, @"User cancelled store picture");
        }
    }];
    
    [self savePhotoWithUrlToAsset:urlToAsset
                  alertController:alertVC
               rootViewController:self.rootViewController
                              yes:yesAction
                               no:noAction
                       completion:completion
     ];
}

- (void)savePhotoWithUrlToAsset:(NSURL *)urlToAsset //!OCLINT(unused method parameter)
                alertController:(UIAlertController *) alertVC
             rootViewController:(UIViewController *) rootVC
                            yes:(UIAlertAction *) yesAction
                             no:(UIAlertAction *) noAction
                     completion:(void(^)(BOOL, NSString *))completion {
    
    self.currentCompletion = completion;
    
    // If a Plist file was provided during initialization, use that one, otherwise use the bundle plist.
    NSDictionary<NSString *, id> *infoPlist = self.defaultPlist ?: NSBundle.mainBundle.infoDictionary;
    
    // Test if app's plist.info has set NSPhotoLibraryUsageDescription key, for camera roll access.
    // if not call the completion(false,"msg") to fail the request and generate an error.
    if (!(infoPlist[@"NSPhotoLibraryUsageDescription"])) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(false, @"Need NSPhotoLibraryUsageDescription set in app's info.plist to save photos.");
            }
        });
        
        return;
    }

    if (@available(iOS 11.0, *)) { //!OCLINT(collapsible if statements)
        // The same check for NSPhotoLibraryAddUsageDescription
        if (!infoPlist[@"NSPhotoLibraryAddUsageDescription"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(false, @"Need NSPhotoLibraryAddUsageDescription set in app's info.plist to save photos.");
                }
            });
            
            return;
        }
    }
    
    if (yesAction) {
        [alertVC addAction: yesAction];
    }
    if (noAction) {
        [alertVC addAction: noAction];
    }
    [alertVC showWithRootController:rootVC];
}

- (void) savePhoto: (nonnull NSURL *)urlToAsset completion: (void(^)(BOOL, NSString *)) completion {
    NSData *theData = [NSData dataWithContentsOfURL:urlToAsset];
    UIImage *theImage = [UIImage imageWithData:theData];
    if (!theImage) {
        if (completion) {
            completion(false, @"Failed to get image");
        }
        return;
    }
    
    UIImageWriteToSavedPhotosAlbum(
                                   theImage,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   nil);
    
    if (completion) {
        completion(YES, @"Success");
    }
}

#pragma mark - Calendar

- (void)createCalendarEventFromString:(nonnull NSString *)eventString completion:(void(^_Nonnull)(BOOL, NSString *_Nonnull))completion {
    [self checkForPermissionAndAddEventFromString:eventString completion:completion];
}


#pragma mark - UIAlertViewDelegate

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo  { //!OCLINT(unused method parameter)
    if (error) {
        if (self.currentCompletion) {
            NSString *msg = [NSString stringWithFormat: @"Saving image failed with error: %@", [error localizedDescription]];
            self.currentCompletion(false, msg);
        }
        
        return;
    }
    
    // succeeded
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(nonnull EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (self.currentCompletion) {
        if (action == EKEventEditViewActionCanceled) {
            self.currentCompletion(false, @"User cancelled");
        }
        else if (action == EKEventEditViewActionDeleted) {
            self.currentCompletion(false, @"User deleted");
        }
        else {
            self.currentCompletion(true, @"Saved");
        }
    }
}

#pragma mark - Internal Methods

- (void)checkForPermissionAndAddEventFromString:(nonnull NSString *)eventString completion:(void(^)(BOOL, NSString *))completion {
    
    self.currentCompletion = completion;

    NSDictionary<NSString *, id> *infoPlist = self.defaultPlist ?: NSBundle.mainBundle.infoDictionary;
    if (!infoPlist[@"NSCalendarsUsageDescription"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(false, @"Need NSCalendarsUsageDescription set in app's info.plist to create calendar events.");
        });
        return;
    }
    
    EKEventStoreRequestAccessCompletionHandler completionHandler = ^(BOOL accessGranted, NSError *error){
        if (accessGranted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self internalAddEvent:eventString completion:completion];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(false, @"User did not give permission for the calendar");
            });
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [PBMDeviceAccessManager.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:completionHandler];
    });
}

- (void)internalAddEvent:(NSString *)eventString
              completion: (void(^)(BOOL, NSString *)) completion {
    NSData *theData = [eventString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    if (!theData) {
        if (completion) {
            completion(false, @"Failed to encode event string");
        }
        return;
    }
    
    NSError *error = nil;
    PBMJsonDictionary *theDict = [NSJSONSerialization JSONObjectWithData:theData options:0 error:&error];
    if (!theDict) {
        if (completion) {
            NSString *errMessage = error ? @"Failed to decode event string" : @"Could not create a dictionary from event string";
            completion(false, errMessage);
        }
        
        return;
    }
    
    // pull values out of the dict
    // Note: Status can't be set in iOS, so we aren't pulling it out here. In addition MRAID contains and ID field that doesn't seem to have an analogue in iOS, so that is not pulled out either.
    NSString *description = theDict[PBMDeviceAccessManagerKeys.DESCRIPTION];
    if (!description) {
        if (completion) {
            completion(false, @"No description found");
        }
        return;
    }
    
    NSString *start = theDict[PBMDeviceAccessManagerKeys.START];
    if (!start) {
        if (completion) {
            completion(false, @"No start time found");
        }
        return;
    }
    
    NSString *location = theDict[PBMDeviceAccessManagerKeys.LOCATION];
    NSString *summary = theDict[PBMDeviceAccessManagerKeys.SUMMARY];
    NSString *end = theDict[PBMDeviceAccessManagerKeys.END];
    NSString *transparency = theDict[PBMDeviceAccessManagerKeys.TRANSPARENCY];
    PBMJsonDictionary *recurrence = theDict[PBMDeviceAccessManagerKeys.RECURRENCE];
    NSString *reminder = theDict[PBMDeviceAccessManagerKeys.REMINDER];
    
    // build the event
    EKEvent *newEvent = [EKEvent eventWithEventStore:PBMDeviceAccessManager.eventStore];
    newEvent.calendar = PBMDeviceAccessManager.eventStore.defaultCalendarForNewEvents;
    
    newEvent.title = description;
    newEvent.location = location;
    
    NSDate *theDate = [[PBMDateFormatService shared] formatISO8601ForString:start];
    if (!theDate) {
        if (completion) {
            completion(false, @"Invalid start time");
        }
        
        return;
    }
    
    newEvent.startDate = theDate;
    
    if (!end) {
        NSDate *endDate = [[PBMDateFormatService shared] formatISO8601ForString:end];
        if (endDate) {
            newEvent.endDate = endDate;
        } else {
            if (completion) {
                completion(false, @"Invalid end time");
            }
            return;
        }
        // no end, but that doesn't mean error?
    }
    
    newEvent.notes = summary;
    
    if (transparency) {
        newEvent.availability = [transparency isEqualToString:PBMDeviceAccessManagerKeys.TRANSPARENT] ? EKEventAvailabilityFree : EKEventAvailabilityBusy;
    }
    
    if (reminder) {
        NSDate *theReminderDate = [[PBMDateFormatService shared] formatISO8601ForString:reminder];
        if (theReminderDate) {
            [newEvent addAlarm:[EKAlarm alarmWithAbsoluteDate:theReminderDate]];
        } else {
            double theReminderOffset = reminder.doubleValue;
            [newEvent addAlarm:[EKAlarm alarmWithRelativeOffset:theReminderOffset]];
        }
    }
    
    EKRecurrenceRule *rule = [PBMDeviceAccessManager createRecurrenceRuleWithDictionary:recurrence];
    if (rule) {
        [newEvent addRecurrenceRule:rule];
    }
    
    // launch the edit controller
    PBMAddEventViewController *eventViewController = [PBMAddEventViewController new];
    eventViewController.deviceAccessManager = self;
    
    eventViewController.eventStore = PBMDeviceAccessManager.eventStore;
    eventViewController.event = newEvent;
    
    eventViewController.editViewDelegate = self;
    [eventViewController showWithRootController:self.rootViewController];
}

// Converts dictionary recurrance values into eventkit values, then creates an eventkit recurrence rule.
+ (nullable EKRecurrenceRule *)createRecurrenceRuleWithDictionary: (nullable PBMJsonDictionary *)dict {
    if (!dict) {
        return nil;
    }
    
    NSString *frequencyString = dict[PBMDeviceAccessManagerKeys.FREQUENCY];
    if (!frequencyString) {
        return nil;
    }
    
    EKRecurrenceFrequency frequency = EKRecurrenceFrequencyYearly;
    if ([frequencyString isEqualToString:PBMDeviceAccessManagerKeys.DAILY]) {
        frequency = EKRecurrenceFrequencyDaily;
    } else if ([frequencyString isEqualToString:PBMDeviceAccessManagerKeys.WEEKLY]) {
        frequency = EKRecurrenceFrequencyWeekly;
    } else if ([frequencyString isEqualToString:PBMDeviceAccessManagerKeys.MONTHLY]) {
        frequency = EKRecurrenceFrequencyMonthly;
    }
    
    NSString *intervalString = dict[PBMDeviceAccessManagerKeys.EXPIRES];
    if (!intervalString) {
        return nil;
    }
    
    NSString *expiresString = dict[PBMDeviceAccessManagerKeys.EXPIRES];
    NSDate* expiresDate = [[PBMDateFormatService shared] formatISO8601ForString:expiresString];
    EKRecurrenceEnd *expires = expiresDate ? [EKRecurrenceEnd recurrenceEndWithEndDate:expiresDate] : nil;
    
    NSArray<NSNumber *> *diw = dict[PBMDeviceAccessManagerKeys.DAYS_IN_WEEK];
    NSArray<EKRecurrenceDayOfWeek *> *daysInWeek = diw ? [self recurrenceDayOfWeekArrayWithArray:diw] : nil;
    
    NSArray<NSNumber *> *daysInMonth = dict[PBMDeviceAccessManagerKeys.DAYS_IN_MONTH];
    NSArray<NSNumber *> *daysInYear = dict[PBMDeviceAccessManagerKeys.DAYS_IN_YEAR];
    NSArray<NSNumber *> *monthsInYear = dict[PBMDeviceAccessManagerKeys.MONTHS_IN_YEAR];
    
    return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency
                                                        interval:intervalString.integerValue
                                                   daysOfTheWeek:daysInWeek
                                                  daysOfTheMonth:daysInMonth
                                                 monthsOfTheYear:monthsInYear
                                                  weeksOfTheYear:nil
                                                   daysOfTheYear:daysInYear
                                                    setPositions:nil
                                                             end:expires];
}

// converts an array of numbers into an equivalant array of event kit recurrent days of the week
+ (nonnull NSArray<EKRecurrenceDayOfWeek *> *)recurrenceDayOfWeekArrayWithArray:(nonnull NSArray<NSNumber *> *)array {
    NSMutableArray<EKRecurrenceDayOfWeek *> *recurrenceDayOfWeekArray = [NSMutableArray<EKRecurrenceDayOfWeek *> new];
    
    for (NSNumber *day in array) {
        if (day && day.intValue > 0 && day.intValue < 8) {
            [recurrenceDayOfWeekArray addObject:[EKRecurrenceDayOfWeek dayOfWeek:day.intValue]];
        }
    }
    
    return recurrenceDayOfWeekArray;
}

@end

#pragma mark - UIAlertController

@implementation UIAlertController (PBMPrivate)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return false;
}

@end

