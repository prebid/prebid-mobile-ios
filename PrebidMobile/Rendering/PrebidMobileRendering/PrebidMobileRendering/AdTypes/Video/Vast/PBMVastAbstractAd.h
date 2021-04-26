//
//  PBMVastAbstractAd.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMVastResponse;
@class PBMVastCreativeAbstract;

//In the VAST XML Structure, <VAST> nodes have 1 or more <Ad> children.
//Each <Ad> has either a <Wrapper> or <InLine> child.
//Wrappers essentially contain another <VAST> tag that can have <Ad>, <Wrapper> and <Inline> children, but all <Wrapper> tags
//Ultimately terminate in <Inline> leaves.

//To represent this, we have this class implemented as abstract and PBMVastWrapperAd and PBMVastInlineAd are concrete.

@interface PBMVastAbstractAd : NSObject

@property (nonatomic, weak, nullable) PBMVastResponse *ownerResponse;
@property (nonatomic, copy, nonnull) NSString *identifier;
@property (nonatomic, assign) NSInteger sequence;

@property (nonatomic, copy, nonnull) NSString *adSystem;
@property (nonatomic, copy, nonnull) NSString *adSystemVersion;

@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *impressionURIs;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *errorURIs;
@property (nonatomic, strong, nonnull) NSMutableArray<PBMVastCreativeAbstract *> *creatives;

@end
