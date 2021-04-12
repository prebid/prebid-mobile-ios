//
//  OXMJSLibraryManager+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMJSLibraryManager.h"
#import "OXMJSLibrary.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXMJSLibraryManager()

@property (strong, nonatomic) NSCache<NSString *, OXMJSLibrary *> *cachedLibraries;

- (void)clearData;
- (NSString *)getLibraryContentsFromBundleWithName:(NSString *)name;
- (void)saveLibraryWithName:(NSString *)fileName jsLibrary:(OXMJSLibrary *)jsLibrary;
- (OXMJSLibrary *)getLibrayFromDiskWithFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
