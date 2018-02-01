/*   Copyright 2017 Prebid.org, Inc.
 
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

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

//! Project version number for PrebidCache.
FOUNDATION_EXPORT double PrebidCacheVersionNumber;

//! Project version string for PrebidCache.
FOUNDATION_EXPORT const unsigned char PrebidCacheVersionString[];

#if !__has_feature(nullability)
#    define nullable
#    define nonnull
#    define __nullable
#    define __nonnull
#endif

@interface PrebidCache : NSObject

// Global cache for easy use
+ (nonnull instancetype)globalCache;

// Opitionally create a different PrebidCache instance with it's own cache directory
- (nonnull instancetype)initWithCacheDirectory:(NSString* __nonnull)cacheDirectory;

- (void)clearCache;
- (void)removeCacheForKey:(NSString* __nonnull)key;

- (BOOL)hasCacheForKey:(NSString* __nonnull)key;

- (NSData* __nullable)dataForKey:(NSString* __nonnull)key;
- (void)setData:(NSData* __nonnull)data forKey:(NSString* __nonnull)key;
- (void)setData:(NSData* __nonnull)data forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSString* __nullable)stringForKey:(NSString* __nonnull)key;
- (void)setString:(NSString* __nonnull)aString forKey:(NSString* __nonnull)key;
- (void)setString:(NSString* __nonnull)aString forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSDate* __nullable)dateForKey:(NSString* __nonnull)key;
- (NSArray* __nonnull)allKeys;

#if TARGET_OS_IPHONE
- (UIImage* __nullable)imageForKey:(NSString* __nonnull)key;
- (void)setImage:(UIImage* __nonnull)anImage forKey:(NSString* __nonnull)key;
- (void)setImage:(UIImage* __nonnull)anImage forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
#else
- (NSImage* __nullable)imageForKey:(NSString* __nonnull)key;
- (void)setImage:(NSImage* __nonnull)anImage forKey:(NSString* __nonnull)key;
- (void)setImage:(NSImage* __nonnull)anImage forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
#endif

- (NSData* __nullable)plistForKey:(NSString* __nonnull)key;
- (void)setPlist:(nonnull id)plistObject forKey:(NSString* __nonnull)key;
- (void)setPlist:(nonnull id)plistObject forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (void)copyFilePath:(NSString* __nonnull)filePath asKey:(NSString* __nonnull)key;
- (void)copyFilePath:(NSString* __nonnull)filePath asKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (nullable id<NSCoding>)objectForKey:(NSString* __nonnull)key;
- (void)setObject:(nonnull id<NSCoding>)anObject forKey:(NSString* __nonnull)key;
- (void)setObject:(nonnull id<NSCoding>)anObject forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

@property(nonatomic) NSTimeInterval defaultTimeoutInterval; // Default is 1 day
@end
