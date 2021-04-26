//
//  PBMORTBApp.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

@class PBMORTBPublisher;
@class PBMORTBAppExtPrebid;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.14: App

//This object should be included if the ad supported content is a non-browser application (typically in
//mobile) as opposed to a website. A bid request must not contain both an App and a Site object. At a
//minimum, it is useful to provide an App ID or bundle, but this is not strictly required.
@interface PBMORTBApp : PBMORTBAbstract
    
//Exchange specific id, recommended
@property (nonatomic, copy, nullable) NSString *id;

//App name
@property (nonatomic, copy, nullable) NSString *name;

//App bundle or package name
@property (nonatomic, copy, nullable) NSString *bundle;

//Domain name of the app
@property (nonatomic, copy, nullable) NSString *domain;

//App store url for an installed app
@property (nonatomic, copy, nullable) NSString *storeurl;

//Array of IAB content categories of the app
@property (nonatomic, copy) NSArray<NSString *> *cat;

//Array of IAB content categories of the current section of the app
@property (nonatomic, copy) NSArray<NSString *> *sectioncat;

//Array of IAB content categories of the current page or view of the app
@property (nonatomic, copy) NSArray<NSString *> *pagecat;

//Application version
@property (nonatomic, copy, nullable) NSString *ver;

//Int. Indicates if the site has a privacy policy where 0 = no and 1 = yes
@property (nonatomic, strong, nullable) NSNumber *privacypolicy;

//Int. Paid status; 0 = app is free, 1 = app is paid
@property (nonatomic, strong, nullable) NSNumber *paid;

//Details about the publisher of the site
@property (nonatomic, strong, nullable) PBMORTBPublisher *publisher;

//Note: Content object not supported
//Details about the content of the site

//Comma seperated list of keywords about the site
@property (nonatomic, copy, nullable) NSString *keywords;

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext is not supported.
@property (nonatomic, strong) PBMORTBAppExtPrebid *extPrebid;

- (instancetype )init;

@end

NS_ASSUME_NONNULL_END
