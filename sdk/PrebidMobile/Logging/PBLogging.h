/*   Copyright 2017 APPNEXUS INC
 
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

#import "PBLogManager.h"

#define PB_DEBUG_MODE 1

/**
 * the message that is logged by the logging module
 */
extern NSString *const kPBLogMessageKey;

/**
 * specifies if the information provided by the message is a info or warning or error
 */
extern NSString *const kPBLogMessageLevelKey;

#if PB_DEBUG_MODE
void _PBLog(PBLogLevel level, NSString *format, ...) NS_FORMAT_FUNCTION(2, 3);
#define PBLogTrace(...) _PBLog(PBLogLevelTrace, __VA_ARGS__)
#define PBLogDebug(...) _PBLog(PBLogLevelDebug, __VA_ARGS__)
#define PBLogInfo(...) _PBLog(PBLogLevelInfo, __VA_ARGS__)
#define PBLogWarn(...) _PBLog(PBLogLevelWarn, __VA_ARGS__)
#define PBLogError(...) _PBLog(PBLogLevelError, __VA_ARGS__)

#else

#define PCLogTrace(...) \
{}
#define PCLogDebug(...) \
{}
#define PCLogInfo(...) \
{}
#define PCLogWarn(...) \
{}
#define PCLogError(...) \
{}

#endif
