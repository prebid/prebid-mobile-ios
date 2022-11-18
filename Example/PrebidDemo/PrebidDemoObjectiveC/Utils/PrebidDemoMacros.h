/*   Copyright 2019-2022 Prebid.org, Inc.
 
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


#define PBMAssertExt(condition, messageFormat, ...)          \
    NSAssert(condition, messageFormat, ##__VA_ARGS__);    \
    if (!condition) {                                     \
        PBMLogError(messageFormat, ##__VA_ARGS__);        \
    }

#define PBMAssert(condition)                              \
    PBMAssertExt(condition, @"Invalid input parameters");

#pragma mark - Memory Managment

#define __deprecated__(s) __attribute__((deprecated(s)))

#define weakify(...) \
    try {} @finally {} \
    macro_dispatcher(weakify, __VA_ARGS__)(__VA_ARGS__)

#define unsafeify(...) \
    try {} @finally {} \
    macro_dispatcher(unsafeify, __VA_ARGS__)(__VA_ARGS__)

#define strongify(...) \
    try {} @finally {} \
    macro_dispatcher(strongify, __VA_ARGS__)(__VA_ARGS__)

#define va_num_args(...) va_num_args_impl(__VA_ARGS__, 5,4,3,2,1)
#define va_num_args_impl(_1,_2,_3,_4,_5,N,...) N

#define macro_dispatcher(func, ...) macro_dispatcher_(func, va_num_args(__VA_ARGS__))
#define macro_dispatcher_(func, nargs) macro_dispatcher__(func, nargs)
#define macro_dispatcher__(func, nargs) func ## nargs

#define strongify1(v) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    __strong __typeof(v) v = v ## _weak_ \
    _Pragma("clang diagnostic pop")

#define strongify2(v_in, v_out) \
    __strong __typeof(v_in) v_out = v_in \


#define weakify1(v) \
    __weak __typeof(v) v ## _weak_ = v \

#define weakify2(v_in, v_out) \
    __weak __typeof(v_in) v_out = v_in \

#define unsafeify1(v) \
    __unsafe_unretained __typeof(v) v ## _weak_ = v \

#define unsafeify2(v_in, v_out) \
    __unsafe_unretained __typeof(v_in) v_out = v_in \
