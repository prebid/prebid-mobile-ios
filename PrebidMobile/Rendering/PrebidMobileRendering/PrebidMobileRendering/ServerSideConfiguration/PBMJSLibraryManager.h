//
//  PBMJSLibraryManager.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMJSLibrary.h"

@protocol PBMServerConnectionProtocol;

typedef NS_ENUM(NSInteger, PBMJSLibraryType) {
    PBMJSLibraryTypeMRAID,
    PBMJSLibraryTypeOMSDK,
};

NS_ASSUME_NONNULL_BEGIN

@interface PBMJSLibraryManager : NSObject

@property (strong, nonatomic, nullable) PBMJSLibrary *remoteMRAIDLibrary;
@property (strong, nonatomic, nullable) PBMJSLibrary *remoteOMSDKLibrary;
@property (strong, nonatomic, nonnull) NSBundle *bundle;

+ (instancetype)sharedManager;
- (nullable NSString *)getMRAIDLibrary;
- (nullable NSString *)getOMSDKLibrary;
- (void)updateJSLibrariesIfNeededWithConnection:(id<PBMServerConnectionProtocol>)connection;

@end

NS_ASSUME_NONNULL_END
