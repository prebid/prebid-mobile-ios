//
//  OXAExternalLinkHandler.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAExternalLinkHandler.h"


@interface OXAExternalLinkHandler()
@property (nonatomic, strong, nonnull, readonly) OXAExternalURLOpenerBlock primaryUrlOpener;
@property (nonatomic, strong, nonnull, readonly) OXAExternalURLOpenerBlock deepLinkUrlOpener;
@end



@implementation OXAExternalLinkHandler

- (instancetype)initWithPrimaryUrlOpener:(OXAExternalURLOpenerBlock)primaryUrlOpener
                       deepLinkUrlOpener:(OXAExternalURLOpenerBlock)deepLinkUrlOpener
                      trackingUrlVisitor:(OXATrackingURLVisitorBlock)trackingUrlVisitor
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
             completion:(OXAURLOpenResultHandlerBlock)completion
onClickthroughExitBlock:(nullable OXMVoidBlock)onClickthroughExitBlock
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

- (OXAExternalLinkHandler *)asDeepLinkHandler {
    return [[OXAExternalLinkHandler alloc] initWithPrimaryUrlOpener:self.deepLinkUrlOpener
                                                  deepLinkUrlOpener:self.deepLinkUrlOpener
                                                 trackingUrlVisitor:self.trackingUrlVisitor];
}

- (OXAExternalLinkHandler *)handlerByAddingUrlOpenAttempter:(OXAURLOpenAttempterBlock)urlOpenAttempter {
    OXAExternalURLOpenerBlock const currentUrlOpener = self.primaryUrlOpener;
    OXAExternalURLOpenerBlock const newCombinedOpener = ^(NSURL *url,
                                                          OXAURLOpenResultHandlerBlock completion,
                                                          OXMVoidBlock onClickthroughExitBlock) {
        urlOpenAttempter(url, ^OXAExternalURLOpenCallbacks * (BOOL willOpenURL) {
            if (willOpenURL) {
                return [[OXAExternalURLOpenCallbacks alloc] initWithUrlOpenedCallback:completion
                                                              onClickthroughExitBlock:onClickthroughExitBlock];
            } else {
                currentUrlOpener(url, completion, onClickthroughExitBlock);
                return [[OXAExternalURLOpenCallbacks alloc] initWithUrlOpenedCallback:^(BOOL urlOpened) {
                    // nop
                } onClickthroughExitBlock:nil];
            }
        });
    };
    return [[OXAExternalLinkHandler alloc] initWithPrimaryUrlOpener:newCombinedOpener
                                                  deepLinkUrlOpener:self.deepLinkUrlOpener
                                                 trackingUrlVisitor:self.trackingUrlVisitor];
}

@end
