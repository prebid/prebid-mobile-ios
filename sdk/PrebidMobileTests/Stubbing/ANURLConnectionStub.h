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

#import <UIKit/UIKit.h>

@interface ANURLConnectionStub : NSObject <NSCopying>

@property (nonatomic, readwrite, strong) NSString *requestURLRegexPatternString;
@property (nonatomic, readwrite, assign) NSInteger responseCode;
@property (nonatomic, readwrite, strong) id responseBody; //can be nsstring or nsdata

+ (ANURLConnectionStub *)stubForPreBidMobileBannerWithAdSize:(CGSize)adSize
                                                        uuid:(NSString *)uuid;
+ (ANURLConnectionStub *)stubForPreBidMobileInterstitialWithUUID:(NSString *)uuid;
+ (ANURLConnectionStub *)stubForPreBidMobileNoBid;

+ (ANURLConnectionStub *)stubForResource:(NSString *)resource
                                  ofType:(NSString *)type;
+ (ANURLConnectionStub *)stubForResource:(NSString *)resource
                                  ofType:(NSString *)type
        withRequestURLRegexPatternString:(NSString *)pattern;
+ (ANURLConnectionStub *)stubForResource:(NSString *)resource
                                  ofType:(NSString *)type
        withRequestURLRegexPatternString:(NSString *)pattern
                                inBundle:(NSBundle *)bundle;

+ (ANURLConnectionStub *)stubForMraidFile;

@end
