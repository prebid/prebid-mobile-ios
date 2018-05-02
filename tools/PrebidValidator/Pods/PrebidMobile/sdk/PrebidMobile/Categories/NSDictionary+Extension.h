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

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Extension)

+ (nonnull instancetype)dictionaryWithString:(nonnull NSString *)string
               withKeyValueSeparatedByString:(nonnull NSString *)keyValueSeparator
            andKeyValuePairSeparatedByString:(nonnull NSString *)keyValuePairSeparator;

- (nonnull instancetype)initWithString:(nonnull NSString *)string
             keyValueSeparatedByString:(nonnull NSString *)keyValueSeparator
      andKeyValuePairSeparatedByString:(nonnull NSString *)keyValuePairSeparator;

- (nonnull NSArray<NSString *> *)arrayRepresentationOfKeyValueSeparatedByString:(nonnull NSString *)keyValueSeparator;

- (nonnull NSString *)stringRepresentationOfKeyValueSeparatedByString:(nonnull NSString *)keyValueSeparator
                                     andKeyValuePairSeparatedByString:(nonnull NSString *)keyValuePairSeparator;

@end

NS_ASSUME_NONNULL_END
