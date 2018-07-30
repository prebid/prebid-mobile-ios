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

#import <Foundation/Foundation.h>
#import "DemandValidator.h"
#import <PrebidMobile/PBBannerAdUnit.h>
#import <PrebidMobile/PBServerRequestBuilder.h>
#import "PBVSharedConstants.h"
#import <PrebidMobile/PBInterstitialAdUnit.h>

@interface DemandValidator()
@property NSInteger testsHasResponded;
@end

@implementation DemandValidator

- (void)startTestWithCompletionHandler:(void (^) (Boolean result)) completionHandler;{
    // Get params from coredata
    NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    BOOL useCache = FALSE;
    if([adServerName isEqualToString: kDFPString]) useCache = TRUE;
    NSString *accountId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBAccountKey];
    NSString *configId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBConfigKey];
    PBAdUnit *adUnit;
    if([adFormatName isEqualToString:@"Banner"]) {
        adUnit = [[PBBannerAdUnit alloc]initWithAdUnitIdentifier:adUnitID andConfigId:configId];
        // set size on adUnit
        if ([adSizeString isEqualToString: kBannerSizeString]) {
            [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(320, 50)];
        } else if ([adSizeString isEqualToString:kMediumRectangleSizeString]) {
            [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(300, 250)];
        } else {
             [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(320, 480)];
        }
    } else {
        adUnit = [[PBInterstitialAdUnit alloc] initWithAdUnitIdentifier:adUnitID andConfigId:configId];
    }
    NSArray *adUnits = [NSArray arrayWithObjects:adUnit, nil];
    // Generate Request for the saved adunits
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:kPBHostKey];
    NSURL *url;
    if ([host isEqualToString:kAppNexusString]) {
        url = [NSURL URLWithString:kAppNexusPrebidServerEndpoint];
    } else if ([host isEqualToString:kRubiconString]) {
        url = [NSURL URLWithString:kRubiconPrebidServerEndpoint];
    }
    [[PBServerRequestBuilder sharedInstance]setHostURL:url];
    NSURLRequest *req = [[PBServerRequestBuilder sharedInstance] buildRequest:adUnits withAccountId:accountId  withSecureParams:true];
    self.request = [[NSString alloc]initWithData:req.HTTPBody encoding:NSUTF8StringEncoding];
    self.testsHasResponded = 0;
    self.testResults = [[NSMutableDictionary alloc] init];
    [self.testResults setObject:[NSNumber numberWithInt:0] forKey:@"successfullTests"];
    for (int i = 0; i<100; i++) {
        [self runTestWithReuqest:req CompletionHandler:^(Boolean result) {
            self.testsHasResponded ++;
            if (result) {
                NSNumber *successfullTests = [self.testResults objectForKey:@"successfullTests"];
                NSNumber *successfullTestsNew = [NSNumber numberWithInt:([successfullTests intValue] + 1)];
                [self.testResults setObject:successfullTestsNew forKey:@"successfullTests"];
            }
            if (self.testsHasResponded == 100) {
                completionHandler(YES);
            }
        }];
    }

}

- (void) startTestWithString:(NSString *)request andCompletionHandler:(void (^)(Boolean))completionHandler
{
    self.request = request;
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://prebid.adnxs.com/pbs/v1/openrtb2/auction"]
                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                   timeoutInterval:1000];
    [mutableRequest setHTTPMethod:@"POST"];
    NSData *data = [request dataUsingEncoding:NSUTF8StringEncoding];
    [mutableRequest setHTTPBody:data];
    [self runTestWithReuqest:mutableRequest CompletionHandler:completionHandler];
   
}

-(void)runTestWithReuqest: (NSURLRequest *) req
        CompletionHandler:(void (^) (Boolean result)) completionHandler;{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                          self.response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                          if(httpResponse.statusCode == 200)
                                          {
                                              NSError *parseError = nil;
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                                              if (parseError) {
                                                  completionHandler(NO);
                                                  return;
                                              }
                                              if (responseDictionary == nil) {
                                                  completionHandler(NO);
                                                  return;
                                              }
                                              if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                                  NSDictionary *response = (NSDictionary *)responseDictionary;
                                                  if ([[response objectForKey:@"seatbid"] isKindOfClass:[NSArray class]]) {
                                                      NSArray *seatbids = (NSArray *)[response objectForKey:@"seatbid"];
                                                      for (id seatbid in seatbids) {
                                                          if ([seatbid isKindOfClass:[NSDictionary class]]) {
                                                              NSDictionary *seatbidDict = (NSDictionary *)seatbid;
                                                              if ([[seatbidDict objectForKey:@"bid"] isKindOfClass:[NSArray class]]) {
                                                                  NSArray *bids = (NSArray *)[seatbidDict objectForKey:@"bid"];
                                                                  for (id bid in bids) {
                                                                      if ([bid isKindOfClass:[NSDictionary class]]) {
                                                                          completionHandler(YES);
                                                                          return;
                                                                      }
                                                                  }
                                                              }
                                                          }
                                                      }
                                                  }
                                              }
                                              // No bid in the response
                                              completionHandler(NO);
                                          }
                                          else
                                          {
                                              completionHandler(NO);
                                          }
                                      }];
    [dataTask resume];
}


@end
