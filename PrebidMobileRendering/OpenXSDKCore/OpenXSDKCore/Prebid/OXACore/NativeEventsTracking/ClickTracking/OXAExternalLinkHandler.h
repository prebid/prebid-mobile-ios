//
//  OXAExternalLinkHandler.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXATrackingURLVisitorBlock.h"
#import "OXAURLOpenAttempterBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAExternalLinkHandler : NSObject

@property (nonatomic, strong, nonnull, readonly) OXATrackingURLVisitorBlock trackingUrlVisitor;
@property (nonatomic, nonnull, readonly) OXAExternalLinkHandler *asDeepLinkHandler;

- (instancetype)initWithPrimaryUrlOpener:(OXAExternalURLOpenerBlock)primaryUrlOpener
                       deepLinkUrlOpener:(OXAExternalURLOpenerBlock)deepLinkUrlOpener
                      trackingUrlVisitor:(OXATrackingURLVisitorBlock)trackingUrlVisitor NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)openExternalUrl:(NSURL *)url
           trackingUrls:(nullable NSArray<NSString *> *)trackingUrls
             completion:(OXAURLOpenResultHandlerBlock)completion
onClickthroughExitBlock:(nullable OXMVoidBlock)onClickthroughExitBlock;

- (OXAExternalLinkHandler *)handlerByAddingUrlOpenAttempter:(OXAURLOpenAttempterBlock)urlOpenAttempter;

@end

NS_ASSUME_NONNULL_END
