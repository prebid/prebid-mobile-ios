//
//  OXANativeClickTrackerBinders.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import UIKit;

#import "OXANativeClickTrackerBinders.h"

#import "OXAVoidBlockBox.h"

#import "OXMMacros.h"

@interface OXANativeClickTrackerBinders ()

@property (nonatomic, class, nonnull, readonly) OXANativeClickTrackerBinderFactoryBlock gestureRecognizerBinder;
@property (nonatomic, class, nonnull, readonly) OXANativeClickTrackerBinderFactoryBlock buttonTargetBinder;

@end



@implementation OXANativeClickTrackerBinders

+ (OXANativeClickTrackerBinderFactoryBlock)gestureRecognizerBinder {
    return ^OXANativeClickTrackerBinderBlock (UIView *view) {
        @weakify(view);
        return ^OXMVoidBlock (OXMVoidBlock onClickBlock) {
            @strongify(view);
            if (view == nil) {
                return ^{};
            }
            [view setUserInteractionEnabled:YES];
            OXAVoidBlockBox * const onClickBox = [[OXAVoidBlockBox alloc] initWithBlock:onClickBlock];
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

+ (OXANativeClickTrackerBinderFactoryBlock)buttonTargetBinder {
    return ^OXANativeClickTrackerBinderBlock (UIView *view) {
        if (![view isKindOfClass:[UIButton class]]) {
            return nil; // binder not compatible with non-UIButtons
        }
        UIButton * const button = (UIButton *)view;
        @weakify(button);
        return ^OXMVoidBlock (OXMVoidBlock onClickBlock) {
            @strongify(button);
            OXAVoidBlockBox * const onClickBox = [[OXAVoidBlockBox alloc] initWithBlock:onClickBlock];
            [button addTarget:onClickBox action:@selector(invoke) forControlEvents:UIControlEventTouchUpInside];
            return ^{
                @strongify(button);
                [button removeTarget:onClickBox action:@selector(invoke) forControlEvents:UIControlEventTouchUpInside];
            };
        };
    };
}

+ (OXANativeClickTrackerBinderFactoryBlock)smartBinder {
    NSArray<OXANativeClickTrackerBinderFactoryBlock> * const factories = @[
        self.buttonTargetBinder,
        self.gestureRecognizerBinder,
    ];
    return ^OXANativeClickTrackerBinderBlock (UIView *view) {
        for (OXANativeClickTrackerBinderFactoryBlock nextFactory in factories) {
            OXANativeClickTrackerBinderBlock nextBinder = nextFactory(view);
            if (nextBinder != nil) {
                return nextBinder;
            }
        }
        return nil;
    };
}

@end
