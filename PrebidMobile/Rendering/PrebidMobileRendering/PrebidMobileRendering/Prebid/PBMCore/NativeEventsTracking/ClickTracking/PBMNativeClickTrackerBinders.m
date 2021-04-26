//
//  PBMNativeClickTrackerBinders.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import UIKit;

#import "PBMNativeClickTrackerBinders.h"

#import "PBMVoidBlockBox.h"

#import "PBMMacros.h"

@interface PBMNativeClickTrackerBinders ()

@property (nonatomic, class, nonnull, readonly) PBMNativeClickTrackerBinderFactoryBlock gestureRecognizerBinder;
@property (nonatomic, class, nonnull, readonly) PBMNativeClickTrackerBinderFactoryBlock buttonTargetBinder;

@end



@implementation PBMNativeClickTrackerBinders

+ (PBMNativeClickTrackerBinderFactoryBlock)gestureRecognizerBinder {
    return ^PBMNativeClickTrackerBinderBlock (UIView *view) {
        @weakify(view);
        return ^PBMVoidBlock (PBMVoidBlock onClickBlock) {
            @strongify(view);
            if (view == nil) {
                return ^{};
            }
            [view setUserInteractionEnabled:YES];
            PBMVoidBlockBox * const onClickBox = [[PBMVoidBlockBox alloc] initWithBlock:onClickBlock];
            UITapGestureRecognizer * const tapRecognizer = [[UITapGestureRecognizer alloc]
                                                            initWithTarget:onClickBox action:@selector(invoke)];
            [view addGestureRecognizer:tapRecognizer];
            return ^{
                @strongify(view);
                id retainClickBox __attribute__((unused)) = onClickBox; // retain recognizer target in this block
                [view removeGestureRecognizer:tapRecognizer];
            };
        };
    };
}

+ (PBMNativeClickTrackerBinderFactoryBlock)buttonTargetBinder {
    return ^PBMNativeClickTrackerBinderBlock (UIView *view) {
        if (![view isKindOfClass:[UIButton class]]) {
            return nil; // binder not compatible with non-UIButtons
        }
        UIButton * const button = (UIButton *)view;
        @weakify(button);
        return ^PBMVoidBlock (PBMVoidBlock onClickBlock) {
            @strongify(button);
            PBMVoidBlockBox * const onClickBox = [[PBMVoidBlockBox alloc] initWithBlock:onClickBlock];
            [button addTarget:onClickBox action:@selector(invoke) forControlEvents:UIControlEventTouchUpInside];
            return ^{
                @strongify(button);
                [button removeTarget:onClickBox action:@selector(invoke) forControlEvents:UIControlEventTouchUpInside];
            };
        };
    };
}

+ (PBMNativeClickTrackerBinderFactoryBlock)smartBinder {
    NSArray<PBMNativeClickTrackerBinderFactoryBlock> * const factories = @[
        self.buttonTargetBinder,
        self.gestureRecognizerBinder,
    ];
    return ^PBMNativeClickTrackerBinderBlock (UIView *view) {
        for (PBMNativeClickTrackerBinderFactoryBlock nextFactory in factories) {
            PBMNativeClickTrackerBinderBlock nextBinder = nextFactory(view);
            if (nextBinder != nil) {
                return nextBinder;
            }
        }
        return nil;
    };
}

@end
