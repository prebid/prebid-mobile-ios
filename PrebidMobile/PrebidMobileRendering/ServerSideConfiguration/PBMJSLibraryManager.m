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

#import "PBMJSLibraryManager.h"
#import "PBMFunctions+Private.h"
#import "PBMError.h"
#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

static NSString * const PBMMRAIDFileName = @"mraid.jslib";
static NSString * const PBMMRAIDBundleName = @"mraid";
static NSString * const PBMMRAIDBundleVersion = @"2.0";
static NSString * const PBMOMSDKFileName = @"omsdk.jslib";
static NSString * const PBMOMSDKBundleName = @"omsdk";
static NSString * const PBMOMSDKBundleVersion = @"1.2.13";
static NSString * const PBMJSLibraryFileDirectory = @"PBMJSLibraries";

@interface PBMJSLibraryManager()

@property (strong, nonatomic) NSCache<NSString *, PBMJSLibrary *> *cachedLibraries;

@end

@implementation PBMJSLibraryManager

+ (instancetype)sharedManager {
    static PBMJSLibraryManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.bundle = [PBMFunctions bundleForSDK];
    }
    return self;
}

#pragma mark - Private Methods

- (NSString *)getPath {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:PBMJSLibraryFileDirectory];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                    attributes:nil error:&error];
    return path;
}

- (NSString *)getPathWithFileName:(NSString *)fileName {
    NSString *path = [self getPath];
    return [path stringByAppendingPathComponent:fileName];
}

- (void)saveLibraryWithName:(NSString *)fileName jsLibrary:(PBMJSLibrary *)jsLibrary {
    NSString *path = [self getPathWithFileName:fileName];
    [NSKeyedArchiver archiveRootObject:jsLibrary toFile:path];
}

- (void)removeLibraryWithName:(NSString *)fileName {
    NSString *path = [self getPathWithFileName:fileName];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error) {
        [PBMError createError:&error message:@"Could not remove jslibrary file" type:PBMErrorTypeInternalError];
    }
}

- (NSString *)getLibraryContentsFromBundleWithName:(NSString *)name {
    NSString *jsPath = [self.bundle pathForResource:name ofType:@"js"];
    
    NSError *error = nil;
    if (!jsPath) {
        [PBMError createError:&error message:[NSString stringWithFormat:@"Could not find %@ script; it will not function", name] type:PBMErrorTypeInternalError];
        return nil;
    }

    NSString *jsScript = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    
    if (!jsScript) {
        [PBMError createError:&error message:[NSString stringWithFormat:@"Could not load %@.js from file", name] type:PBMErrorTypeInternalError];
        return nil;
    }
    
    return jsScript;
}

- (PBMJSLibrary *)getLibrayFromDiskWithFileName:(NSString *)fileName {
    NSString *path = [self getPathWithFileName:fileName];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    if (!data) {
        return nil;
    }

    PBMJSLibrary *library = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return library;
}

- (NSString *)getJSLibraryWithName:(NSString *)name bundleName:(NSString *)bundleName bundleVersion:(NSString *)bundleVersion {
    //check cached library
    PBMJSLibrary *cachedLibrary = [self.cachedLibraries objectForKey:name];
    if (cachedLibrary) {
        return cachedLibrary.contentsString;
    }
    //check saved library on disk
    PBMJSLibrary *savedLibrary = [self getLibrayFromDiskWithFileName:name];
    if (savedLibrary) {
        [self.cachedLibraries setObject:savedLibrary forKey:name];
        return savedLibrary.contentsString;
    }
    
    NSString *contentsFromBundle = [self getLibraryContentsFromBundleWithName:bundleName];
    if (contentsFromBundle) {
        PBMJSLibrary *library = [PBMJSLibrary new];
        library.contentsString = contentsFromBundle;
        library.version = bundleVersion;
        [self.cachedLibraries setObject:library forKey:name];
        return contentsFromBundle;
    }
    
    return nil;
}

- (void)updateJSLibraryIfNeededWithConnection:(id<PrebidServerConnectionProtocol>)connection remoteLibrary:(PBMJSLibrary *)remoteLibrary bundleVersion:(NSString *)bundleVersion fileName:(NSString *)fileName {
    if (!remoteLibrary) {
        return;
    }
    
    //compare version with bundled file
    if ([remoteLibrary.version compare:bundleVersion options:NSNumericSearch] == NSOrderedAscending) {
        return;
    }
    
    NSString *urlString = [remoteLibrary.downloadURL absoluteString];
    @weakify(self);
    [connection download:urlString callback:^(PrebidServerResponse *response) {
        @strongify(self);
        if (!self) { return; }
        
        PBMLogInfo(@"Server Side Configuration: The %@ was updated to the version %@", fileName, remoteLibrary.version);
        //updating contents string
        NSString *contentsString = [[NSString alloc] initWithData:response.rawData encoding:NSUTF8StringEncoding];
        remoteLibrary.contentsString = contentsString;
        //saving library into disk memory
        [self saveLibraryWithName:fileName jsLibrary:remoteLibrary];
        //saving library to NSCache
        [self.cachedLibraries setObject:remoteLibrary forKey:fileName];
    }];
}

/**
 For debug use only!
 */
- (void)clearData {
    //clear disk
    [self removeLibraryWithName:PBMMRAIDFileName];
    [self removeLibraryWithName:PBMOMSDKFileName];
    
    //clear memory cache
    [self.cachedLibraries removeAllObjects];
}

#pragma mark - Public Methods

- (NSString *)getMRAIDLibrary {
    return [self getJSLibraryWithName:PBMMRAIDFileName bundleName:PBMMRAIDBundleName bundleVersion:PBMMRAIDBundleVersion];
}

- (NSString *)getOMSDKLibrary {
    return [self getJSLibraryWithName:PBMOMSDKFileName bundleName:PBMOMSDKBundleName bundleVersion:PBMOMSDKBundleVersion];
}

- (void)updateJSLibrariesIfNeededWithConnection:(id<PrebidServerConnectionProtocol>)connection {
    [self updateJSLibraryIfNeededWithConnection:connection remoteLibrary:self.remoteMRAIDLibrary bundleVersion:PBMMRAIDBundleVersion fileName:PBMMRAIDFileName];
    [self updateJSLibraryIfNeededWithConnection:connection remoteLibrary:self.remoteOMSDKLibrary bundleVersion:PBMOMSDKBundleVersion fileName:PBMOMSDKFileName];
}

@end
