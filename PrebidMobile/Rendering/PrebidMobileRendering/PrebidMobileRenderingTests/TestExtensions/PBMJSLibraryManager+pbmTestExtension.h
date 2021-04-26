//
//  OXMJSLibraryManager+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "PBMJSLibraryManager.h"
#import "PBMJSLibrary.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMJSLibraryManager()

@property (strong, nonatomic) NSCache<NSString *, PBMJSLibrary *> *cachedLibraries;

- (void)clearData;
- (NSString *)getLibraryContentsFromBundleWithName:(NSString *)name;
- (void)saveLibraryWithName:(NSString *)fileName jsLibrary:(PBMJSLibrary *)jsLibrary;
- (PBMJSLibrary *)getLibrayFromDiskWithFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
