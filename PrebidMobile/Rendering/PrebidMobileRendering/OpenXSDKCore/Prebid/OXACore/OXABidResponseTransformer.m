//
//  OXABidResponseTransformer.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABidResponseTransformer.h"
#import "OXABidResponse+Internal.h"
#import "OXAError.h"
#import "OXMServerResponse.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXABidResponseTransformer

+ (OXABidResponse *)transformResponse:(OXMServerResponse *)response error:(NSError **)error {
    NSString * const responseBody = [[NSString alloc] initWithData:response.rawData encoding:NSUTF8StringEncoding];
    if ([responseBody containsString:@"Invalid request"]) {
        if (error) {
            *error = [self classifyRequestError:responseBody];
        }
        return nil;
    }
    if (!response.jsonDict) {
        if (error) {
            *error = [OXAError jsonDictNotFound];
        }
        return nil;
    }
    OXABidResponse * const bidResponse = [[OXABidResponse alloc] initWithJsonDictionary:response.jsonDict];
    if (!bidResponse) {
        if (error) {
            *error = [OXAError responseDeserializationFailed];
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
        return [OXAError invalidConfigId];
    }
    if ([responseBody containsString:@"Stored Request with ID"] || [responseBody containsString:@"No stored request found"]) {
        return [OXAError invalidAccountId];
    }
    if ([responseBody containsString:@"Invalid request: Request imp[0].banner.format"] || [responseBody containsString:@"Request imp[0].banner.format"] || [responseBody containsString:@"Unable to set interstitial size list"]) {
        return [OXAError invalidSize];
    }
    return [OXAError serverError:responseBody];
}

@end
