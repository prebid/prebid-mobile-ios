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

#import <Foundation/Foundation.h>
#import "PBAdUnit.h"
#import "PBBidManager.h"
#import "PBBidResponseDelegate.h"

@interface PBServerAdapter : NSObject

- (nonnull instancetype)initWithAccountId:(nonnull NSString *)accountId;

//@property (nonatomic, assign, readwrite) PBPrimaryAdServerType primaryAdServer;

@property (nonatomic, assign) BOOL shouldCacheLocal;

- (void)requestBidsWithAdUnits:(nullable NSArray<PBAdUnit *> *)adUnits
                  withDelegate:(nonnull id<PBBidResponseDelegate>)delegate;

@end
