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

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

+ (instancetype)dictionaryWithString:(NSString *)string
       withKeyValueSeparatedByString:(NSString *)keyValueSeparator
    andKeyValuePairSeparatedByString:(NSString *)keyValuePairSeparator {
    NSDictionary *newDictionary = [[NSDictionary alloc] initWithString:string
                                             keyValueSeparatedByString:keyValueSeparator
                                      andKeyValuePairSeparatedByString:keyValuePairSeparator];
    return (newDictionary);
}

- (instancetype)initWithString:(NSString *)string
           keyValueSeparatedByString:(NSString *)keyValueSeparator
    andKeyValuePairSeparatedByString:(NSString *)keyValuePairSeparator {
    NSArray<NSString *> *__nonnull keyValueStrings = [string componentsSeparatedByString:@","];
    NSMutableArray<NSString *> *__nonnull keys = [[NSMutableArray alloc] initWithCapacity:[keyValueStrings count]];
    NSMutableArray<NSString *> *__nonnull values = [[NSMutableArray alloc] initWithCapacity:[keyValueStrings count]];

    for (NSString *keyValueString in keyValueStrings) {
        NSArray<NSString *> *__nonnull keyValuePair = [keyValueString componentsSeparatedByString:@":"];
        NSString *__nonnull key = keyValuePair[0];
        NSString *__nonnull value = keyValuePair[1];

        [keys addObject:key];
        [values addObject:value];
    }
    if ((self = [self initWithObjects:values forKeys:keys])) {
    }

    return (self);
}

- (NSArray<NSString *> *)arrayRepresentationOfKeyValueSeparatedByString:(NSString *)keyValueSeparator {
    NSMutableArray *__nullable keyValueStrings = [[NSMutableArray alloc] initWithCapacity:[self count]];

    for (NSString *__nonnull key in [self allKeys]) {
        NSString *__nonnull value = self[key];
        NSString *__nonnull keyValueString = [[NSString alloc] initWithFormat:@"%@%@%@", key, keyValueSeparator, value];

        [keyValueStrings addObject:keyValueString];
    }
    return (keyValueStrings);
}

- (NSString *)stringRepresentationOfKeyValueSeparatedByString:(NSString *)keyValueSeparator
                             andKeyValuePairSeparatedByString:(NSString *)keyValuePairSeparator {
    NSArray *__nonnull keyValueStringArray = [self arrayRepresentationOfKeyValueSeparatedByString:keyValueSeparator];

    return ([keyValueStringArray componentsJoinedByString:keyValuePairSeparator]);
}

@end
