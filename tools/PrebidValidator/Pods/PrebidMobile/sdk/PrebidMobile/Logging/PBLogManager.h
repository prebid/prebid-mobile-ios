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
/**
 The lower the filter level, the more logs will be shown.
 For example, `PBLogLevelInfo` will display messages from
 `PBLogLevelInfo,` `PBLogLevelWarn,` and `PBLogLevelError.`
 The default level is `PBLogLevelWarn`
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PBLogLevel) {
    PBLogLevelAll = 0,
    PBLogLevelTrace = 10,
    PBLogLevelDebug = 20,
    PBLogLevelInfo = 30,
    PBLogLevelWarn = 40,
    PBLogLevelError = 50,
    PBLogLevelOff = 60
};

/**
 Use the `PBLogManager` methods to set the desired level of log filter.
 */
@interface PBLogManager : NSObject

/**
 Gets the current log filter level.
 */
+ (PBLogLevel)getPBLogLevel;

/**
 Sets the log filter level.
 */
+ (void)setPBLogLevel:(PBLogLevel)level;

@end
