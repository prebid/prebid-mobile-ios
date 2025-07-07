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

@class PBMLog;

#define PBMLogError( s, ... ) [PBMLog error:[NSString stringWithFormat:(s), ##__VA_ARGS__] filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define PBMLogInfo( s, ... ) [PBMLog info:[NSString stringWithFormat:(s), ##__VA_ARGS__] filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define PBMLogDebug( s, ... ) [PBMLog debug:[NSString stringWithFormat:(s), ##__VA_ARGS__] filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define PBMLogVerbose( s, ... ) [PBMLog verbose:[NSString stringWithFormat:(s), ##__VA_ARGS__] filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define PBMLogWarn( s, ... ) [PBMLog warn:[NSString stringWithFormat:(s), ##__VA_ARGS__] filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define PBMLogSevere( s, ... ) [PBMLog severe:[NSString stringWithFormat:(s), ##__VA_ARGS__] filename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
#define PBMLogWhereAmI() [PBMLog whereAmIWithFilename:[NSString stringWithUTF8String:__FILE__] line:__LINE__ function:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
