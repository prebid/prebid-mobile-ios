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

#import "PBLogging.h"

NSString *const kPBLoggingNotification = @"kPBLoggingNotification";
NSString *const kPBLogMessageKey = @"kPBLogMessageKey";
NSString *const kPBLogMessageLevelKey = @"kPBLogMessageLevelKey";



void _PBLog(PBLogLevel level, NSString *format, ...) {
    if ([PBLogManager getPBLogLevel] <= level) {
        format = [NSString stringWithFormat:@"Prebid -AS: %@", format];
        va_list args;
        va_start(args, format);
        NSString *fullString = [[NSString alloc] initWithFormat:format
                                                      arguments:args];
        va_end(args);
        NSLog(@"%@", fullString);
    }
}
