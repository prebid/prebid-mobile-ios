/*
 *    Copyright 2018 Prebid.org, Inc.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import "ColorTool.h"

@implementation ColorTool

+ (UIColor *)prebidBlue
{
    return [UIColor colorWithRed:0.23 green:0.53 blue:0.76 alpha:1.0];
}
+ (UIColor *)prebidOrange
{
    return [UIColor colorWithRed:0.93 green:0.59 blue:0.12 alpha:1.0];
}

+ (UIColor *)prebidGrey
{
    return [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
}

+ (UIColor *) prebidCodeSnippetGrey
{
    return [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0];
}


@end
