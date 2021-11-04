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

#import "XCTestCase+Throwing.h"
 
static NSString * const iterationExceptionName = @"UITest Iteration Exception";

@implementation XCTestCase (Throwing)

- (void)failIterationRunning {
    NSException *myException = [NSException exceptionWithName:iterationExceptionName
                                                       reason:iterationExceptionName
                                                     userInfo:nil];
    @throw myException;
}

- (BOOL)attemptRunningIteration:(void (NS_NOESCAPE ^)(void))runnable {
    @try {
        runnable();
        return YES;
    }
    @catch (NSException *e) {
        if([e.name isEqualToString:iterationExceptionName]) {
            return NO;
        } else {
            @throw e;
        }
    }
}

@end
