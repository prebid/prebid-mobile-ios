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

#import <Foundation/Foundation.h>

@class Log;

#define LogError( s, ... ) [Log error:s filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define LogInfo( s, ... ) [Log info:s filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define LogDebug( s, ... ) [Log debug:s filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define LogVerbose( s, ... ) [Log verbose:s filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define LogWarn( s, ... ) [Log warn:s filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define LogSevere( s, ... ) [Log severe:s filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define LogWhereAmI() [Log whereAmIWithFilename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
