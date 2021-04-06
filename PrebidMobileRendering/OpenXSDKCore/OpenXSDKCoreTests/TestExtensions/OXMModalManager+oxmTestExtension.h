//
//  OXMModalManager+oxmTestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#ifndef OXMModalManager_oxmTestExtension_h
#define OXMModalManager_oxmTestExtension_h

#import "OXMModalManager.h"

@interface OXMModalManager ()

//The last item in this stack represents the view & display properties currently being displayed.
@property (nonatomic, strong, nonnull, readonly) NSMutableArray<OXMModalState *> *modalStateStack;

- (void)popModal;
- (void)removeModal:(nonnull OXMModalState *)modalState;

@end

#endif /* OXMModalManager_oxmTestExtension_h */
