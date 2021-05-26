/*   Copyright 2018-2019 Prebid.org, Inc.
 
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



#pragma mark - Constants.

extern NSString * const  kFauxMediationAdapterClassDoesNotExist;
extern NSString * const  OK_RESULT_CB_URL;



#pragma mark - Simple diagnostics for tests.

#define  TESTTRACE()              NSLog(@"  TEST TRACE  %s", __PRETTY_FUNCTION__)
#define  TESTTRACEM(format, ...)  NSLog(@"  TEST TRACE  %s -- %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ##__VA_ARGS__])

#define  TESTTRACEJSON(jsonString)                                                                                      \
            {                                                                                                           \
                NSData        *objectData  = [jsonString dataUsingEncoding:NSUTF8StringEncoding];                       \
                NSError       *error;                                                                                   \
                NSDictionary  *json        = [NSJSONSerialization JSONObjectWithData: objectData                        \
                                                                             options: NSJSONReadingMutableContainers    \
                                                                               error: &error];                          \
                TESTTRACEM(@"\n\t%@=%@", @ #jsonString, json);                                                          \
            }




#pragma mark - PBTestGlobal

@interface PBTestGlobal : NSObject
    //EMPTY
@end

