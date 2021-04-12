//
//  OXMVastAbstractAd.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXMVastResponse;
@class OXMVastCreativeAbstract;

//In the VAST XML Structure, <VAST> nodes have 1 or more <Ad> children.
//Each <Ad> has either a <Wrapper> or <InLine> child.
//Wrappers essentially contain another <VAST> tag that can have <Ad>, <Wrapper> and <Inline> children, but all <Wrapper> tags
//Ultimately terminate in <Inline> leaves.

//To represent this, we have this class implemented as abstract and OXMVastWrapperAd and OXMVastInlineAd are concrete.

@interface OXMVastAbstractAd : NSObject

@property (nonatomic, weak, nullable) OXMVastResponse *ownerResponse;
@property (nonatomic, copy, nonnull) NSString *identifier;
@property (nonatomic, assign) NSInteger sequence;

@property (nonatomic, copy, nonnull) NSString *adSystem;
@property (nonatomic, copy, nonnull) NSString *adSystemVersion;

@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *impressionURIs;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *errorURIs;
@property (nonatomic, strong, nonnull) NSMutableArray<OXMVastCreativeAbstract *> *creatives;

@end
