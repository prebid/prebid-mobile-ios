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

- (void)startTestWithCompletionHandler:(void (^) (void)) completionHandler;{
    // Get params from coredata
    NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    adUnitID = @"/19968336/PrebidMobileValidator_Banner_300x250";
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    BOOL useCache = FALSE;
    if([adServerName isEqualToString: kDFPString]) useCache = TRUE;
    NSString *accountId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBAccountKey];
    accountId = @"aecd6ef7-b992-4e99-9bb8-65e2d984e1dd";
    NSString *configId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBConfigKey];
    configId = @"05cf943f-0f70-44e3-a49e-bb6f1fb4e98b";
    
    PBAdUnit *adUnit;
    if([adFormatName isEqualToString:@"Banner"]) {
        adUnit = [[PBBannerAdUnit alloc]initWithAdUnitIdentifier:adUnitID andConfigId:configId];
        // set size on adUnit
        if ([adSizeString isEqualToString: kSizeString320x50]) {
            [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(320, 50)];
        } else if ([adSizeString isEqualToString:kSizeString300x250]) {
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
    self.testsHasResponded = 0;
    self.testResults = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *bidders = [[NSMutableDictionary alloc] init];
    [self.testResults setObject:bidders forKey:@"bidders"];
    [self.testResults setObject:[[NSString alloc]initWithData:req.HTTPBody encoding:NSUTF8StringEncoding] forKey:@"request"];
    for (int i = 0; i<100; i++) {
        [self runTestWithReuqest:req CompletionHandler:^() {
            self.testsHasResponded ++;
            if (self.testsHasResponded == 100) {
                // Calculate total bids
                // Calculate average CPM
                // Calculate average response time
                int totalBids = 0;
                double totalCPM = 0;
                NSMutableDictionary *bidders = [self.testResults objectForKey:@"bidders"];
                for (NSString *key in bidders.allKeys) {
                    NSMutableDictionary *details = [bidders objectForKey:key];
                    double totalPrice = [[details objectForKey:@"cpm"] doubleValue];
                    int bids = [[details objectForKey:@"bid"] intValue];
                    totalBids = totalBids + bids;
                    totalCPM = totalCPM + totalPrice;
                    [details setObject:[NSNumber numberWithDouble:(totalPrice/bids)] forKey:@"cpm"];
                }
                double avgCPM = totalCPM/totalBids;
                [self.testResults setObject:[NSNumber numberWithInt:totalBids] forKey:@"totalBids"];
                [self.testResults setObject:[NSNumber numberWithDouble: avgCPM] forKey:@"avgCPM"];
                completionHandler();
            }
        }];
    }

}

-(void)runTestWithReuqest: (NSURLRequest *) req
        CompletionHandler:(void (^)(void)) completionHandler;{
    NSMutableURLRequest *reqMutable = [req mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"DemandValidationRequest" inRequest:reqMutable];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:reqMutable completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                          NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                          if(httpResponse.statusCode == 200)
                                          {
                                              NSError *parseError = nil;
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                                              if (!parseError && responseDictionary) {
                                                  NSMutableDictionary *bidderResponseStatus = [[NSMutableDictionary alloc] init];
                                                  NSDictionary *responseMillis = [[responseDictionary objectForKey:@"ext"] objectForKey:@"responsetimemillis"];
                                                  NSMutableDictionary *bidders = [self.testResults objectForKey:@"bidders"];
                                                  // 0 means no bid, 1 means time out, 2 means error, 3 means bid
                                                  for (NSString * key in responseMillis.allKeys) {
                                                      // by default status is no bid
                                                      [bidderResponseStatus setObject:@"0" forKey:key];
                                                      // init test result for the first time
                                                      NSMutableDictionary *bidderDetails = [bidders objectForKey:key];
                                                      if (bidderDetails == nil) {
                                                          bidderDetails = [[NSMutableDictionary alloc] init];
                                                          [bidderDetails setObject:[NSNumber numberWithInt:0] forKey:@"bid"];
                                                          [bidderDetails setObject:[NSNumber numberWithInt:0] forKey:@"nobid"];
                                                          [bidderDetails setObject:[NSNumber numberWithInt:0] forKey:@"timeout"];
                                                          [bidderDetails setObject:[NSNumber numberWithInt:0] forKey:@"error"];
                                                          [bidderDetails setObject:[NSNumber numberWithDouble:0] forKey:@"cpm"];
                                                          [bidderDetails setObject:responseString forKey:@"serverResponse"];
                                                      }
                                                      [bidders setObject:bidderDetails forKey:key];
                                                  }
                                        
                                                  if ([[responseDictionary objectForKey:@"seatbid"] isKindOfClass:[NSArray class]]) {
                                                      NSArray *seatbids = (NSArray *)[responseDictionary objectForKey:@"seatbid"];
                                                      for (id seatbid in seatbids) {
                                                          if ([seatbid isKindOfClass:[NSDictionary class]]) {
                                                              NSDictionary *seatbidDict = (NSDictionary *)seatbid;
                                                              if ([[seatbidDict objectForKey:@"bid"] isKindOfClass:[NSArray class]]) {
                                                                  NSArray *bids = (NSArray *)[seatbidDict objectForKey:@"bid"];
                                                                  for (id bid in bids) {
                                                                      if ([bid isKindOfClass:[NSDictionary class]]) {
                                                                          // if bid, set the status to 3
                                                                          NSString *bidderName = [seatbid objectForKey:@"seat"];
                                                                          [bidderResponseStatus setObject:@"3" forKey:bidderName];
                                                                          NSMutableDictionary *bidderDetails = [bidders objectForKey:bidderName];
                                                                          // increase bid number
                                                                          NSNumber *original = [bidderDetails objectForKey:@"bid"];
                                                                          NSNumber *new = [NSNumber numberWithInt:([original intValue] +1)];
                                                                          [bidderDetails setObject:new forKey:@"bid"];
                                                                          // increase total cpm
                                                                          double price = [[bid objectForKey:@"price"] doubleValue];
                                                                          price = price + [[bidderDetails objectForKey:@"cpm"] doubleValue];
                                                                          [bidderDetails setObject:[NSNumber numberWithDouble:price] forKey:@"cpm"];
                                                                          
                                                                      }
                                                                  }
                                                              }
                                                          }
                                                      }
                                                  }
                                                  // if bidder error, then set the status to 2
                                                  if ([[responseDictionary objectForKey:@"ext"] objectForKey:@"errors"] != nil) {
                                                      NSDictionary *bidderErrors = [[responseDictionary objectForKey:@"ext"] objectForKey:@"errors"];
                                                      for (NSString * key in bidderErrors.allKeys) {
                                                          [bidderResponseStatus setObject:@"2" forKey:key];
                                                      }
                                                  }
                                                  // if bidder time out, then set the status to 1
                                                  // todo: need an example
                                                  for(NSString *key in bidderResponseStatus.allKeys) {
                                                      NSMutableDictionary *bidderDetails = [bidders objectForKey:key];
                                                      if ([[bidderResponseStatus objectForKey:key] isEqualToString:@"0"]) {
                                                          NSNumber *original = [bidderDetails objectForKey:@"nobid"];
                                                          NSNumber *new = [NSNumber numberWithInt:([original intValue] +1)];
                                                          [bidderDetails setObject:new forKey:@"nobid"];
                                                      } else if ([[bidderResponseStatus objectForKey:key] isEqualToString:@"1"]) {
                                                          NSNumber *original = [bidderDetails objectForKey:@"timeout"];
                                                          NSNumber *new = [NSNumber numberWithInt:([original intValue] +1)];
                                                          [bidderDetails setObject:new forKey:@"timeout"];
                                                      } else if ([[bidderResponseStatus objectForKey:key] isEqualToString:@"2"]) {
                                                          NSNumber *original = [bidderDetails objectForKey:@"error"];
                                                          NSNumber *new = [NSNumber numberWithInt:([original intValue] +1)];
                                                          [bidderDetails setObject:new forKey:@"error"];
                                                      }
                                                  }
                                                  [self.testResults setObject:bidders forKey:@"bidders"];
                                              }
                                          }
                                          completionHandler();
                                      }];
    [dataTask resume];
}

@end
