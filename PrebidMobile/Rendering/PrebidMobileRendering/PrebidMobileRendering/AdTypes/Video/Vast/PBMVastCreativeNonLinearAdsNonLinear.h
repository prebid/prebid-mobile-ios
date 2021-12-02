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

#import <Foundation/Foundation.h>
#import "PBMVastTrackingEvents.h"
#import "PBMVastResourceContainerProtocol.h"

@interface PBMVastCreativeNonLinearAdsNonLinear : NSObject <PBMVastResourceContainerProtocol>

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong, nonnull) PBMVastTrackingEvents *vastTrackingEvents;

@property (nonatomic, copy, nullable) NSString *clickThroughURI;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *clickTrackingURIs;

@property (nonatomic, copy, nullable) NSString *apiFramework;
@property (nonatomic, copy, nullable) NSString *identifier             NS_SWIFT_NAME(id);
@property (nonatomic, assign) BOOL scalable;
@property (nonatomic, assign) BOOL maintainAspectRatio;
@property (nonatomic, assign) NSTimeInterval minSuggestedDuration;
@property (nonatomic, assign) NSInteger assetWidth;
@property (nonatomic, assign) NSInteger assetHeight;

// PBMVastResourceContainer
@property (nonatomic, assign) PBMVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

@end
