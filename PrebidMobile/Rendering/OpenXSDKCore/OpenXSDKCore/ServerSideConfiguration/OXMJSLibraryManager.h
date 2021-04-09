//
//  OXMJSLibraryManager.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMJSLibrary.h"

@protocol OXMServerConnectionProtocol;

typedef NS_ENUM(NSInteger, OXMJSLibraryType) {
    OXMJSLibraryTypeMRAID,
    OXMJSLibraryTypeOMSDK,
};

NS_ASSUME_NONNULL_BEGIN

@interface OXMJSLibraryManager : NSObject

@property (strong, nonatomic, nullable) OXMJSLibrary *remoteMRAIDLibrary;
@property (strong, nonatomic, nullable) OXMJSLibrary *remoteOMSDKLibrary;
@property (strong, nonatomic, nonnull) NSBundle *bundle;

+ (instancetype)sharedManager;
- (nullable NSString *)getMRAIDLibrary;
- (nullable NSString *)getOMSDKLibrary;
- (void)updateJSLibrariesIfNeededWithConnection:(id<OXMServerConnectionProtocol>)connection;

@end

NS_ASSUME_NONNULL_END
