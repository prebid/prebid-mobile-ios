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

// This category is only useful when NSURLSession is present

@interface NSURLRequest (HTTPBodyTesting)
/**
 *   Unfortunately, when sending POST requests (with a body) using NSURLSession,
 *   by the time the request arrives at OHHTTPStubs, the HTTPBody of the
 *   NSURLRequest has been reset to nil.
 *
 *   You can use this method to retrieve the HTTPBody for testing and use it to
 *   conditionally stub your requests.
 */
- (NSData *)PBHTTPStubs_HTTPBody;

@end
