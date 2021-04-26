//
//  OXMModalManager+oxmTestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMModalManager.h"

@interface PBMModalManager ()

//The last item in this stack represents the view & display properties currently being displayed.
@property (nonatomic, strong, nonnull, readonly) NSMutableArray<PBMModalState *> *modalStateStack;

- (void)popModal;
- (void)removeModal:(nonnull PBMModalState *)modalState;

@end

