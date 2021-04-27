/*   Copyright 2018-2019 Prebid.org, Inc.
 
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




@interface PBURLConnectionStub : NSObject <NSCopying>

@property (nonatomic, readwrite, strong) NSString *requestURL;
@property (nonatomic, readwrite, assign) NSInteger responseCode;
@property (nonatomic, readwrite, strong) id responseBody; //can be nsstring or nsdata

+ (PBURLConnectionStub *)stubForStandardBannerWithAdSize:(CGSize)adSize
                                                 content:(NSString *)content;

+ (PBURLConnectionStub *)stubForStandardBannerWithAdSize:(CGSize)adSize
                                     contentFromResource:(NSString *)resource
                                                  ofType:(NSString *)type;

+ (PBURLConnectionStub *)stubForResource:(NSString *)resource
                                  ofType:(NSString *)type;

+ (PBURLConnectionStub *)stubForResource:(NSString *)resource
                                  ofType:(NSString *)type
        withRequestURL:(NSString *)pattern;

+ (PBURLConnectionStub *)stubForResource:(NSString *)resource
                                  ofType:(NSString *)type
        withRequestURL:(NSString *)pattern
                                inBundle:(NSBundle *)bundle;



/**
 *  Enable or disable the stubs on a given `NSURLSessionConfiguration`.
 *
 *  @param enabled If `YES`, enables the stubs for this `NSURLSessionConfiguration`.
 *                 If `NO`, disable the stubs and let all the requests hit the real world
 *  @param sessionConfig The NSURLSessionConfiguration on which to enabled/disable the stubs
 *
 *  @note OHHTTPStubs are enabled by default on newly created `defaultSessionConfiguration`
 *        and `ephemeralSessionConfiguration`, so there is no need to call this method with
 *        `YES` for stubs to work. You generally only use this if you want to disable
 *        `OHTTPStubs` per `NSURLSession` by calling it before building the `NSURLSession`
 *        with the `NSURLSessionConfiguration`.
 *
 *  @note Important: As usual according to the way `NSURLSessionConfiguration` works, you
 *        MUST set this property BEFORE creating the `NSURLSession`. Once the `NSURLSession`
 *        object is created, they use a deep copy of the `NSURLSessionConfiguration` object
 *        used to create them, so changing the configuration later does not affect already
 *        created sessions.
 */
+ (void)setEnabled:(BOOL)enabled forSessionConfiguration:(NSURLSessionConfiguration *)sessionConfig;

/**
 *  Whether stubs are enabled or disabled on a given `NSURLSessionConfiguration`
 *
 *  @param sessionConfig The NSURLSessionConfiguration on which to enable/disable the stubs
 *
 *  @return If `YES` the stubs are enabled for sessionConfig. If `NO` then the stubs are disabled
 */
+ (BOOL)isEnabledForSessionConfiguration:(NSURLSessionConfiguration *)sessionConfig;

@end
