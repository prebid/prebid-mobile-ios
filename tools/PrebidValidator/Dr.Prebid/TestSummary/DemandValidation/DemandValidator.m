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
#import "PBVSharedConstants.h"
#import "DemandRequestBuilder.h"
#import "AppDelegate.h"

@import PrebidMobile;

@interface DemandValidator()
@property NSInteger testsHasResponded;
@end

@implementation DemandValidator

- (void)startTestWithCompletionHandler:(void (^) (void)) completionHandler;{
    // Get params from coredata
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
  
    NSString *accountId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBAccountKey];
    NSString *configId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBConfigKey];
    
    NSMutableArray* array = [NSMutableArray new];
    AdUnit *adUnit;
    if([adFormatName isEqualToString:@"Banner"]) {
        if ([adSizeString isEqualToString: kSizeString320x50]) {
            [array addObject:[NSValue valueWithCGSize:CGSizeMake(320, 50)]];
            
        } else if ([adSizeString isEqualToString: kSizeString300x250]) {
            [array addObject:[NSValue valueWithCGSize:CGSizeMake(300, 250)]];
            
        } else if ([adSizeString isEqualToString:kSizeString320x480]){
            [array addObject:[NSValue valueWithCGSize:CGSizeMake(320, 480)]];
           
        } else if ([adSizeString isEqualToString:kSizeString320x100]){
            [array addObject:[NSValue valueWithCGSize:CGSizeMake(320, 100)]];
            
        } else if ([adSizeString isEqualToString:kSizeString300x600]){
            [array addObject:[NSValue valueWithCGSize:CGSizeMake(300, 600)]];
            
        } 
        else {
            [array addObject:[NSValue valueWithCGSize:CGSizeMake(728, 90)]];
            
        }
        adUnit = [[BannerAdUnit alloc] initWithConfigId:configId size:[array.lastObject CGSizeValue]];
        
    } else if([adFormatName isEqualToString:kInterstitialString]) {
        adUnit = [[InterstitialAdUnit alloc] initWithConfigId:configId];
    } else if([adFormatName isEqualToString:kNativeString]) {
        
        NativeRequest *request = ((AppDelegate*)[UIApplication sharedApplication].delegate).nativeRequest;
        request.configId = configId;
        [array addObject:[NSValue valueWithCGSize:CGSizeMake(1, 1)]];
        adUnit = request;
    }
    NSArray *adUnits = [NSArray arrayWithObjects:adUnit, nil];
    // Generate Request for the saved adunits
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:kPBHostKey];
    NSURL *url = [NSURL URLWithString:kAppNexusPrebidServerEndpoint];
    if ([host isEqualToString:kRubiconString]) {
        url = [NSURL URLWithString:kRubiconPrebidServerEndpoint];
        Prebid.shared.prebidServerHost = PrebidHostRubicon;
    } else if ([host isEqualToString:kCustomString]){
        NSString *urlString = [[NSUserDefaults standardUserDefaults] stringForKey:kCustomPrebidServerEndpoint];
        url =[NSURL URLWithString:urlString];
        Prebid.shared.prebidServerHost = PrebidHostCustom;
        [Prebid.shared setCustomPrebidServerWithUrl:urlString error:nil];
    }
    DemandRequestBuilder *builder = [[DemandRequestBuilder alloc] init];
    builder.configId = configId;
    builder.adSizes = array;
    builder.hostURL = url;
    NSURLRequest *req = [builder buildRequest:adUnits withAccountId:accountId withSecureParams:YES];
    
    self.testsHasResponded = 0;
    self.testResults = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *bidders = [[NSMutableDictionary alloc] init];
    [self.testResults setObject:bidders forKey:@"bidders"];
    [self.testResults setObject:@"" forKey:@"error"];
    [self.testResults setObject:[NSNumber numberWithInteger:200] forKey:@"responseStatus"];
    [self.testResults setObject:[[NSString alloc]initWithData:req.HTTPBody encoding:NSUTF8StringEncoding] forKey:@"request"];
    [self.testResults setObject:[NSNumber numberWithInt:0] forKey:@"totalBids"];
    for (int i = 0; i<100; i++) {
        [self runTestWithReuqest:req CompletionHandler:^() {
            if (self.testsHasResponded == 100) {
                // Calculate total bids
                // Calculate average CPM
                // Calculate average response time
                int totalBids = 0;
                double totalCPM = 0;
                double avgResponseTime = 0;
                NSMutableDictionary *bidders = [self.testResults objectForKey:@"bidders"];
                for (NSString *key in bidders.allKeys) {
                    NSMutableDictionary *details = [bidders objectForKey:key];
                    double totalPrice = [[details objectForKey:@"cpm"] doubleValue];
                    int bids = [[details objectForKey:@"bid"] intValue];
                    totalBids = totalBids + bids;
                    totalCPM = totalCPM + totalPrice;
                    avgResponseTime = avgResponseTime + [[details objectForKey:@"responseTime"] doubleValue];
                    [details setObject:[NSNumber numberWithDouble:(totalPrice/bids)] forKey:@"cpm"];
                }
                avgResponseTime = avgResponseTime/bidders.count;
                double avgCPM = totalCPM/totalBids;
                [self.testResults setObject:[NSNumber numberWithDouble: avgCPM] forKey:@"avgCPM"];
                [self.testResults setObject:[NSNumber numberWithDouble:avgResponseTime] forKey:@"avgResponse"];
                completionHandler();
            }
        }];
    }
    
}

-(void)runTestWithReuqest: (NSURLRequest *) req
        CompletionHandler:(void (^)(void)) completionHandler {
    NSMutableURLRequest *reqMutable = [req mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"DemandValidationRequest" inRequest:reqMutable];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:reqMutable completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          self.testsHasResponded ++;
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                          NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                          BOOL containBids = NO;
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
                                                          [bidderDetails setObject:@"" forKey:@"serverResponse"];
                                                          [bidderDetails setObject:responseMillis[key] forKey:@"responseTime"];
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
                                                                          containBids = YES;
                                                                          NSString *bidderName = [seatbid objectForKey:@"seat"];
                                                                          [bidderResponseStatus setObject:@"3" forKey:bidderName];
                                                                          NSMutableDictionary *bidderDetails = [bidders objectForKey:bidderName];
                                                                          // increase bid number
                                                                          
                                                                          if([[[bid objectForKey:@"ext"] objectForKey:@"prebid"] objectForKey:@"targeting"] != nil){
                                                                              NSNumber *original = [bidderDetails objectForKey:@"bid"];
                                                                              NSNumber *new = [NSNumber numberWithInt:([original intValue] +1)];
                                                                              [bidderDetails setObject:new forKey:@"bid"];
                                                                              [bidderDetails setObject:responseString forKey:@"serverResponse"];
                                                                          }
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
                                                  if (containBids) {
                                                      NSNumber *original = [self.testResults objectForKey:@"totalBids"];
                                                      NSNumber *new = [NSNumber numberWithInt:([original intValue] +1)];
                                                      [self.testResults setObject:new forKey:@"totalBids"];
                                                  }
                                                  // if bidder error, then set the status to 2
                                                  if ([[responseDictionary objectForKey:@"ext"] objectForKey:@"errors"] != nil) {
                                                      NSDictionary *bidderErrors = [[responseDictionary objectForKey:@"ext"] objectForKey:@"errors"];
                                                      NSString *host = [[NSUserDefaults standardUserDefaults]stringForKey:kPBHostKey];
                                                      if ([kRubiconString isEqualToString:host]) {
                                                          for (NSString *key in bidderErrors.allKeys) {
                                                              NSArray *errors = [bidderErrors mutableArrayValueForKey:key];
                                                              if (errors != nil && errors.count >0 ) {
                                                                  [bidderResponseStatus setObject:@"2" forKey:key];
                                                              }
                                                          }
                                                      } else {
                                                          for (NSString * key in bidderErrors.allKeys) {
                                                              [bidderResponseStatus setObject:@"2" forKey:key];
                                                          }
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
                                                  if (self.testsHasResponded == 100) {
                                                      for(NSString *key in bidderResponseStatus.allKeys) {
                                                          NSMutableDictionary *bidderDetails = [bidders objectForKey:key];
                                                          if ([[bidderDetails objectForKey:@"serverResponse"] isEqualToString:@""]) {
                                                              [bidderDetails setObject:responseString forKey:@"serverResponse"];
                                                          }
                                                      }
                                                  }
                                                  [self.testResults setObject:bidders forKey:@"bidders"];
                                              }
                                          } else {
                                              [self.testResults setObject:[NSNumber numberWithInteger:httpResponse.statusCode] forKey:@"responseStatus"];
                                              [self.testResults setObject:responseString forKey:@"error"];
                                          }
                                          completionHandler();
                                      }];
    [dataTask resume];
}

@end
