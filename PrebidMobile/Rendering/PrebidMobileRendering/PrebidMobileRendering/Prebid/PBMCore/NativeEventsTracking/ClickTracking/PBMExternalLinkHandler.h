//
//  PBMExternalLinkHandler.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

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
