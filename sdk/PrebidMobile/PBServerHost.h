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

/**
 * Prebid Server host selection enumerator to be passed in by the user
 */
typedef NS_ENUM(NSUInteger, PBSHost) {
    PBSHostAppNexus = 0,
    PBSHostRubicon
};

@interface PBServerHost : NSObject

/**
 * Shared instance of the PBServerHost class
 */
+ (nonnull instancetype)sharedInstance;

#ifdef DEBUG
+ (void)resetSharedInstance;
#endif

/**
 * The Prebid Server host to be used for auctions. Set before registering ad units.
 * If not used, Prebid Server host defaults to AppNexus.
 */
@property (nonatomic, assign, readwrite) PBSHost pbsHost;

@end
