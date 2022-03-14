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

#import "PBMBidResponseTransformer.h"
#import "PBMError.h"
#import "PBMServerResponse.h"
#import "PBMORTBAbstract+Protected.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

@implementation PBMBidResponseTransformer

+ (BidResponse *)transformResponse:(PBMServerResponse *)response error:(NSError **)error {
    NSString * const responseBody = [[NSString alloc] initWithData:response.rawData encoding:NSUTF8StringEncoding];
    if ([responseBody containsString:@"Invalid request"]) {
        if (error) {
            *error = [self classifyRequestError:responseBody];
        }
        return nil;
    }
    if (!response.jsonDict) {
        if (error) {
            *error = [PBMError jsonDictNotFound];
        }
        return nil;
    }
    BidResponse * const bidResponse = [[BidResponse alloc] initWithJsonDictionary:response.jsonDict];
    if (!bidResponse) {
        if (error) {
            *error = [PBMError responseDeserializationFailed];
        }
        return nil;
    }
    if (error) {
        *error = nil;
    }
    return bidResponse;
}

+ (NSError *)classifyRequestError:(NSString *)responseBody {
    if ([responseBody containsString:@"Stored Imp with ID"] || [responseBody containsString:@"No stored imp found"]) {
        return [PBMError invalidConfigId];
    }
    if ([responseBody containsString:@"Stored Request with ID"] || [responseBody containsString:@"No stored request found"]) {
        return [PBMError invalidAccountId];
    }
    if ([responseBody containsString:@"Invalid request: Request imp[0].banner.format"] || [responseBody containsString:@"Request imp[0].banner.format"] || [responseBody containsString:@"Unable to set interstitial size list"]) {
        return [PBMError invalidSize];
    }
    return [PBMError serverError:responseBody];
}

@end
