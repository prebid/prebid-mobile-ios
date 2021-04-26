//
//  PBMExternalLinkHandler.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMExternalLinkHandler.h"


@interface PBMExternalLinkHandler()
@property (nonatomic, strong, nonnull, readonly) PBMExternalURLOpenerBlock primaryUrlOpener;
@property (nonatomic, strong, nonnull, readonly) PBMExternalURLOpenerBlock deepLinkUrlOpener;
@end



@implementation PBMExternalLinkHandler

- (instancetype)initWithPrimaryUrlOpener:(PBMExternalURLOpenerBlock)primaryUrlOpener
                       deepLinkUrlOpener:(PBMExternalURLOpenerBlock)deepLinkUrlOpener
                      trackingUrlVisitor:(PBMTrackingURLVisitorBlock)trackingUrlVisitor
{
    if (!(self = [super init])) {
        return nil;
    }
    _primaryUrlOpener = primaryUrlOpener;
    _deepLinkUrlOpener = deepLinkUrlOpener;
    _trackingUrlVisitor = trackingUrlVisitor;
    return self;
}

- (void)openExternalUrl:(NSURL *)url
           trackingUrls:(nullable NSArray<NSString *> *)trackingUrls
             completion:(PBMURLOpenResultHandlerBlock)completion
onClickthroughExitBlock:(nullable PBMVoidBlock)onClickthroughExitBlock
{
    self.primaryUrlOpener(url, ^(BOOL success) {
        if (success) {
            self.trackingUrlVisitor(trackingUrls);
            completion(YES);
        } else {
            completion(NO);
        }
    }, onClickthroughExitBlock);
}

- (PBMExternalLinkHandler *)asDeepLinkHandler {
    return [[PBMExternalLinkHandler alloc] initWithPrimaryUrlOpener:self.deepLinkUrlOpener
                                                  deepLinkUrlOpener:self.deepLinkUrlOpener
                                                 trackingUrlVisitor:self.trackingUrlVisitor];
}

- (PBMExternalLinkHandler *)handlerByAddingUrlOpenAttempter:(PBMURLOpenAttempterBlock)urlOpenAttempter {
    PBMExternalURLOpenerBlock const currentUrlOpener = self.primaryUrlOpener;
    PBMExternalURLOpenerBlock const newCombinedOpener = ^(NSURL *url,
                                                          PBMURLOpenResultHandlerBlock completion,
                                                          PBMVoidBlock onClickthroughExitBlock) {
        urlOpenAttempter(url, ^PBMExternalURLOpenCallbacks * (BOOL willOpenURL) {
            if (willOpenURL) {
                return [[PBMExternalURLOpenCallbacks alloc] initWithUrlOpenedCallback:completion
                                                              onClickthroughExitBlock:onClickthroughExitBlock];
            } else {
                currentUrlOpener(url, completion, onClickthroughExitBlock);
                return [[PBMExternalURLOpenCallbacks alloc] initWithUrlOpenedCallback:^(BOOL urlOpened) {
                    // nop
                } onClickthroughExitBlock:nil];
            }
        });
    };
    return [[PBMExternalLinkHandler alloc] initWithPrimaryUrlOpener:newCombinedOpener
                                                  deepLinkUrlOpener:self.deepLinkUrlOpener
                                                 trackingUrlVisitor:self.trackingUrlVisitor];
}

@end
