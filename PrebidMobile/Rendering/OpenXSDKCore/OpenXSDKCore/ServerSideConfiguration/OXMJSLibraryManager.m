//
//  JSLibraryManager.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMJSLibraryManager.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMServerResponse.h"
#import "OXMFunctions+Private.h"
#import "OXMError.h"

#import "OXMMacros.h"

static NSString * const OXMMRAIDFileName = @"mraid.jslib";
static NSString * const OXMMRAIDBundleName = @"mraid";
static NSString * const OXMMRAIDBundleVersion = @"2.0";
static NSString * const OXMOMSDKFileName = @"omsdk.jslib";
static NSString * const OXMOMSDKBundleName = @"omsdk";
static NSString * const OXMOMSDKBundleVersion = @"1.2.13";
static NSString * const OXMJSLibraryFileDirectory = @"OXMJSLibraries";

@interface OXMJSLibraryManager()

@property (strong, nonatomic) NSCache<NSString *, OXMJSLibrary *> *cachedLibraries;

@end

@implementation OXMJSLibraryManager

+ (instancetype)sharedManager {
    static OXMJSLibraryManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.bundle = [OXMFunctions bundleForSDK];
    }
    return self;
}

#pragma mark - Private Methods

- (NSString *)getPath {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:OXMJSLibraryFileDirectory];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                    attributes:nil error:&error];
    return path;
}

- (NSString *)getPathWithFileName:(NSString *)fileName {
    NSString *path = [self getPath];
    return [path stringByAppendingPathComponent:fileName];
}

- (void)saveLibraryWithName:(NSString *)fileName jsLibrary:(OXMJSLibrary *)jsLibrary {
    NSString *path = [self getPathWithFileName:fileName];
    [NSKeyedArchiver archiveRootObject:jsLibrary toFile:path];
}

- (void)removeLibraryWithName:(NSString *)fileName {
    NSString *path = [self getPathWithFileName:fileName];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error) {
        [OXMError createError:&error message:@"Could not remove jslibrary file" type:OXAErrorTypeInternalError];
    }
}

- (NSString *)getLibraryContentsFromBundleWithName:(NSString *)name {
    NSString *jsPath = [self.bundle pathForResource:name ofType:@"js"];
    
    NSError *error = nil;
    if (!jsPath) {
        [OXMError createError:&error message:[NSString stringWithFormat:@"Could not find %@ script; it will not function", name] type:OXAErrorTypeInternalError];
        return nil;
    }

    NSString *jsScript = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    
    if (!jsScript) {
        [OXMError createError:&error message:[NSString stringWithFormat:@"Could not load %@.js from file", name] type:OXAErrorTypeInternalError];
        return nil;
    }
    
    return jsScript;
}

- (OXMJSLibrary *)getLibrayFromDiskWithFileName:(NSString *)fileName {
    NSString *path = [self getPathWithFileName:fileName];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    if (!data) {
        return nil;
    }

    OXMJSLibrary *library = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return library;
}

- (NSString *)getJSLibraryWithName:(NSString *)name bundleName:(NSString *)bundleName bundleVersion:(NSString *)bundleVersion {
    //check cached library
    OXMJSLibrary *cachedLibrary = [self.cachedLibraries objectForKey:name];
    if (cachedLibrary) {
        return cachedLibrary.contentsString;
    }
    //check saved library on disk
    OXMJSLibrary *savedLibrary = [self getLibrayFromDiskWithFileName:name];
    if (savedLibrary) {
        [self.cachedLibraries setObject:savedLibrary forKey:name];
        return savedLibrary.contentsString;
    }
    
    NSString *contentsFromBundle = [self getLibraryContentsFromBundleWithName:bundleName];
    if (contentsFromBundle) {
        OXMJSLibrary *library = [OXMJSLibrary new];
        library.contentsString = contentsFromBundle;
        library.version = bundleVersion;
        [self.cachedLibraries setObject:library forKey:name];
        return contentsFromBundle;
    }
    
    return nil;
}

- (void)updateJSLibraryIfNeededWithConnection:(id<OXMServerConnectionProtocol>)connection remoteLibrary:(OXMJSLibrary *)remoteLibrary bundleVersion:(NSString *)bundleVersion fileName:(NSString *)fileName {
    if (!remoteLibrary) {
        return;
    }
    
    //compare version with bundled file
    if ([remoteLibrary.version compare:bundleVersion options:NSNumericSearch] == NSOrderedAscending) {
        return;
    }
    
    NSString *urlString = [remoteLibrary.downloadURL absoluteString];
    @weakify(self);
    [connection download:urlString callback:^(OXMServerResponse *response) {
        @strongify(self);
        OXMLogInfo(@"Server Side Configuration: The %@ was updated to the version %@", fileName, remoteLibrary.version);
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
    [self removeLibraryWithName:OXMMRAIDFileName];
    [self removeLibraryWithName:OXMOMSDKFileName];
    
    //clear memory cache
    [self.cachedLibraries removeAllObjects];
}

#pragma mark - Public Methods

- (NSString *)getMRAIDLibrary {
    return [self getJSLibraryWithName:OXMMRAIDFileName bundleName:OXMMRAIDBundleName bundleVersion:OXMMRAIDBundleVersion];
}

- (NSString *)getOMSDKLibrary {
    return [self getJSLibraryWithName:OXMOMSDKFileName bundleName:OXMOMSDKBundleName bundleVersion:OXMOMSDKBundleVersion];
}

- (void)updateJSLibrariesIfNeededWithConnection:(id<OXMServerConnectionProtocol>)connection {
    [self updateJSLibraryIfNeededWithConnection:connection remoteLibrary:self.remoteMRAIDLibrary bundleVersion:OXMMRAIDBundleVersion fileName:OXMMRAIDFileName];
    [self updateJSLibraryIfNeededWithConnection:connection remoteLibrary:self.remoteOMSDKLibrary bundleVersion:OXMOMSDKBundleVersion fileName:OXMOMSDKFileName];
}

@end
