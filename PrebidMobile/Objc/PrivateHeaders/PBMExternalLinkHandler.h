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

#import "PBMTrackingURLVisitorBlock.h"
#import "PBMURLOpenAttempterBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMExternalLinkHandler : NSObject

@property (nonatomic, strong, nonnull, readonly) PBMTrackingURLVisitorBlock trackingUrlVisitor;
@property (nonatomic, nonnull, readonly) PBMExternalLinkHandler *asDeepLinkHandler;

- (instancetype)initWithPrimaryUrlOpener:(PBMExternalURLOpenerBlock)primaryUrlOpener
                       deepLinkUrlOpener:(PBMExternalURLOpenerBlock)deepLinkUrlOpener
                      trackingUrlVisitor:(PBMTrackingURLVisitorBlock)trackingUrlVisitor NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)openExternalUrl:(NSURL *)url
           trackingUrls:(nullable NSArray<NSString *> *)trackingUrls
             completion:(PBMURLOpenResultHandlerBlock)completion
onClickthroughExitBlock:(nullable PBMVoidBlock)onClickthroughExitBlock;

- (PBMExternalLinkHandler *)handlerByAddingUrlOpenAttempter:(PBMURLOpenAttempterBlock)urlOpenAttempter;

@end

NS_ASSUME_NONNULL_END
