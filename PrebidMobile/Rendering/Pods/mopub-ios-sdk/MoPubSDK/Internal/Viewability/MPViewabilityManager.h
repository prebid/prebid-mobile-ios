//
//  MPViewabilityManager.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPScheduledDeallocationAdAdapter.h"
#import "OMIDPartner.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Notification that is fired when at least one viewability vendor is disabled.
 */
extern NSString *const kDisableViewabilityTrackerNotification;

/**
 Manages all integrated Viewability SDKs.
 */
@interface MPViewabilityManager : NSObject

/**
 A Boolean value that indicates whether the Viewability tracking is enabled.
 */
@property (nonatomic, readonly) BOOL isEnabled;

/**
 A Boolean value that indicates whether the manager is initialized.
 */
@property (nonatomic, readonly) BOOL isInitialized;

#pragma mark - Initialization

/**
 Singleton instance of the `ViewabilityManager`.
 */
+ (instancetype)sharedManager;

/**
 Asynchronously initializes the manager’s internal state and Open Measurement SDK.
 In the event that `initializeWithCompletion:` is called when the manager is already initialized,
 the method will complete immediately. If Viewability has been disabled prior to initializing,
 the method will complete immediately without initializing.
 @param complete Completion block that is fired with the current manager initialization status.
 */
- (void)initializeWithCompletion:(void(^)(BOOL))complete;

#pragma mark - Disabling Viewability

/**
 Disables Viewability measurement for the duration of the app session. Currently running Viewability trackers will continue to function to completion.
 */
- (void)disableViewability;

#pragma mark - Open Measurement

/**
 The locally cached Open Measurement JS Library.
 If the Open Measurement JS Library has not been cached yet, the bundled omid.js resource will be immediately cached and returned.
 */
@property (nonatomic, nullable, copy, readonly) NSString *omidJsLibrary;

/**
 The Open Measurement `Partner` object that is used to represent the MoPub SDK for all Viewability tracking events.
 If the manager has not been initialized, or if Viewability is disabled, this value will be nil.
 */
@property (nonatomic, nullable, strong, readonly) OMIDMopubPartner *omidPartner;

/**
 Open Measurement partner identifier.
 */
@property (nonatomic, copy, readonly) NSString *omidPartnerId;

/**
 Version of the Open Measurement SDK.
 */
@property (nonatomic, copy, readonly) NSString *omidVersion;

/**
 Injects the Open Measurement Javascript hooks into the inputted HTML ad markup.
 In the event that the manager has not been initialized, or if Viewability is disabled, the original inputted value will be returned.
 */
- (NSString * _Nullable)injectViewabilityIntoAdMarkup:(NSString * _Nullable)html;

#pragma mark - Scheduled Adapter Deallocation

/**
 Schedules an adapter for deallocation. This is to allow Open Measurement SDK enough time to send out any
 session end signals. Scheduling an adapter for deallocation will automatically call @c stopViewabilitySession
 on the @c adapter. Deallocation will occur on the main thread.
 In the event that the manager has not been initialized, or if Viewability is disabled, nothing will be done.
 @note It is the responsibility of the caller to transfer ownership of the reference to @c MPViewabilityManager.
 @note This is primarily used for webview-based creatives.
 @param adapter Adapter scheduled for deallocation.
 */
- (void)scheduleAdapterForDeallocation:(id<MPScheduledDeallocationAdAdapter>)adapter;

#pragma mark - Unavailable

/**
 `init` is not available. Use `sharedManager` instead.
 */
- (instancetype)init __attribute__((unavailable("init not available")));

/**
 `new` is not available. Use `sharedManager` instead.
 */
+ (instancetype)new __attribute__((unavailable("new not available")));

@end

NS_ASSUME_NONNULL_END
