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

#import "PBMPathBuilder.h"

#pragma mark - Constants

static NSString * const PBMPathBuilderApiVersion  = @"1.0";
static NSString * const PBMPathBuilderRoute = @"ma";
static NSString * const PBMPathBuilderVideoRoute = @"v";
static NSString * const PBMPathBuilderSecureProtocol = @"https";
static NSString * const PBMPathBuilderAcjResource = @"acj";
static NSString * const PBMPathBuilderVASTResource = @"av";

#pragma mark - Implementation

@implementation PBMPathBuilder

#pragma mark - PBMURLPathBuilder

+ (NSString *)buildBaseURLForDomain:(NSString *)domain {
    return [NSString stringWithFormat:@"%@://%@",
            PBMPathBuilderSecureProtocol,
            domain];
}

+ (NSString *)buildURLPathForDomain:(NSString *)domain path:(NSString *)path {
    return [NSString stringWithFormat:@"%@://%@/%@/%@/",
            PBMPathBuilderSecureProtocol,
            domain,
            path,
            PBMPathBuilderApiVersion];
}

+ (NSString *)buildACJURLPathForDomain:(NSString *)domain {
    return [[PBMPathBuilder buildURLPathForDomain:domain path:PBMPathBuilderRoute] stringByAppendingString:PBMPathBuilderAcjResource];
}

+ (NSString *)buildVASTURLPathForDomain:(NSString *)domain {
    return [[PBMPathBuilder buildURLPathForDomain:domain path:PBMPathBuilderVideoRoute] stringByAppendingString:PBMPathBuilderVASTResource];
}

@end
