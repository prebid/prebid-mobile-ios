/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMVastParser.h"

#import "PBMVastGlobals.h"
#import "PBMVastResponse.h"
#import "PBMVastInlineAd.h"
#import "PBMVastWrapperAd.h"
#import "PBMVastAbstractAd.h"
#import "PBMVastCreativeLinear.h"
#import "PBMVastCreativeNonLinearAds.h"
#import "PBMVastCreativeCompanionAds.h"
#import "PBMVastResourceContainerProtocol.h"
#import "PBMVastIcon.h"
#import "PBMVastCreativeCompanionAdsCompanion.h"
#import "PBMVastCreativeNonLinearAdsNonLinear.h"

#import "PBMVideoVerificationParameters.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@interface PBMVastParser ()

@property (nonatomic, assign) BOOL parseSuccessful;

@end

@implementation PBMVastParser

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.parseSuccessful = false;
        self.currentElementName = @"";
        self.currentElementContent = @"";
        self.elementPath = [NSMutableArray array];
    }
    return self;
}

- (PBMVastResponse *)parseAdsResponse:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    
    self.currentElementContext = @"";
    self.elementPath = [NSMutableArray array];
    [parser parse];
    
    return self.parseSuccessful ? self.parsedResponse : nil;
}

//The Companion, and NonLinear and Icon tags can all have StaticResource, IFrameResource and
//HTMLResource tag children. To represent this, the PBMVastIcon,
//PBMVastCreativeCompanionAdsCompanion, and PBMVastCreativeNonLinearAdsNonLinear classes
//all conform to PBMVastResourceContainer.
-(void)parseResourceForType:(PBMVastResourceType)type {
    
    if (!self.creative) {
        PBMLogError(@"No applicable creative");
        return;
    }
    
    id <PBMVastResourceContainerProtocol> container = [self extractCreativeContainer];

    //Bail if unsuccessful
    if (!container) {
        PBMLogError(@"No applicable container to apply currentElementContent of [%@] to. Type is %ld.",
                    self.currentElementContent, (long)type);
        return;
    }
    
    //Fill out PBMVastResourceContainer fields
    container.resourceType = type;
    container.resource = self.currentElementContent;
    if (type == PBMVastResourceTypeStaticResource) {
        container.staticType = self.currentElementAttributes[@"creativeType"];
    }
}

- (BOOL)parseBool:(NSString *)str {
    if (!str) {
        return false;
    }
    return [str isEqualToString: @"true"];
}

- (NSInteger)parseInt:(NSString *)str {
    if (!str) {
        return 0;
    }
    return str.integerValue;
}

- (float)parseFloat:(NSString *)str {
    if (!str) {
        return 0;
    }
    return str.floatValue;
}

-(NSTimeInterval)parseTimeInterval:(NSString *)str {
    if (!str) {
        return 0;
    }
    
    NSArray *components = [[[str componentsSeparatedByString:@":"] reverseObjectEnumerator] allObjects];
    NSTimeInterval totalSeconds = 0;
    NSInteger componentIndex = 0;
    
    for (NSString *component in components) {
        switch (componentIndex) {
            case 0: totalSeconds += component.doubleValue; break; //Seconds
            case 1: totalSeconds += component.doubleValue * 60; break; //Minutes
            case 2: totalSeconds += component.doubleValue * 60 * 60; break; //Hours
                
            default: {
                PBMLogError(@"Unable to parse time string: %@", str);
                return 0;
            }
        }
        
        componentIndex += 1;
    }
    
    return totalSeconds;
}

- (NSString *)parseString:(NSString *)str {
    if (!str) {
        return @"";
    }
    return str;
}

-(NSNumber *)parseSkipOffset:(NSString *)str {
    if (!str) {
        return nil;
    }
    
    NSTimeInterval interval = [self parseTimeInterval:str];
    return [NSNumber numberWithDouble:interval];
}

#pragma mark - NSXMLParserDelegate

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    self.parsedResponse = [PBMVastResponse new];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    // sent when the parser has completed parsing. If this is encountered, the parse was successful.
    self.parseSuccessful = YES;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
    // sent when the parser finds an element start tag.
    
    [self.elementPath addObject:elementName];
    self.currentElementName = elementName;
    self.currentElementAttributes = attributeDict;
    self.currentElementContent = @"";
    
    if ([elementName isEqualToString:@"VAST"]) {
        self.parsedResponse.version = attributeDict[@"version"];
    }
    else if ([elementName isEqualToString: @"Ad"]) {
        self.adAttributes = attributeDict;
    }
    else if ([elementName isEqualToString: @"InLine"]) {
        self.inlineAd = [PBMVastInlineAd new];
        self.ad = self.inlineAd;
    }
    else if ([elementName isEqualToString: @"Wrapper"]) {
        
        PBMVastWrapperAd *pbmWrapperAd = [PBMVastWrapperAd new];
        
        id followAdditionalWrappersKey = attributeDict[@"followAdditionalWrappers"];
        if (followAdditionalWrappersKey) {
            pbmWrapperAd.followAdditionalWrappers = [self parseBool:followAdditionalWrappersKey];
        }
        
        id allowMultipleAdsKey = attributeDict[@"allowMultipleAds"];
        if (allowMultipleAdsKey) {
            pbmWrapperAd.allowMultipleAds = [self parseBool:allowMultipleAdsKey];
        }
        
        id fallbackOnNoAdKey = attributeDict[@"fallbackOnNoAd"];
        if (fallbackOnNoAdKey) {
            pbmWrapperAd.fallbackOnNoAd = [self parseBool:fallbackOnNoAdKey];
        }
        
        self.wrapperAd = pbmWrapperAd;
        self.ad = pbmWrapperAd;
    }
    else if ([elementName isEqualToString: @"Creative"]) {
        self.creativeAttributes = attributeDict;
    }
    else if ([elementName isEqualToString: @"Linear"]) {
        PBMVastCreativeLinear *creative = [PBMVastCreativeLinear new];
        creative.skipOffset = [self parseSkipOffset:attributeDict[@"skipoffset"]];
        self.creative = creative;
    }
    else if ([elementName isEqualToString: @"CompanionAds"]) {
        PBMVastCreativeCompanionAds *creative = [PBMVastCreativeCompanionAds new];
        creative.requiredMode = [self parseString:attributeDict[@"required"]];
        self.creative = creative;
    }
    else if ([elementName isEqualToString: @"Companion"]) {
        PBMVastCreativeCompanionAds *pbmVastCreativeCompanionAds = (PBMVastCreativeCompanionAds*) self.creative;
        if (!pbmVastCreativeCompanionAds) {
            PBMLogError(@"Error - expected current creative to be PBMVastCreativeCompanionAds");
            return;
        }
        
        PBMVastCreativeCompanionAdsCompanion *companion = [PBMVastCreativeCompanionAdsCompanion new];
        companion.companionIdentifier = attributeDict[@"id"];
        companion.width = [self parseInt: attributeDict[@"width"]];
        companion.height = [self parseInt: attributeDict[@"height"]];
        companion.assetWidth = [self parseInt: attributeDict[@"assetWidth"]];
        companion.assetHeight = [self parseInt: attributeDict[@"assetHeight"]];
        [pbmVastCreativeCompanionAds.companions addObject:companion];
    }
    else if ([elementName isEqualToString: @"NonLinearAds"]) {
        self.creative = [PBMVastCreativeNonLinearAds new];
    }
    else if ([elementName isEqualToString: @"NonLinear"]) {
        PBMVastCreativeNonLinearAds *pbmVastCreativeNonLinearAds = (PBMVastCreativeNonLinearAds*) self.creative;
        if (!pbmVastCreativeNonLinearAds) {
            PBMLogError(@"Expected current creative to be PBMVastCreativeNonLinearAds");
            return;
        }
        
        PBMVastCreativeNonLinearAdsNonLinear *pbmVastCreativeNonLinearAdsNonLinear = [PBMVastCreativeNonLinearAdsNonLinear new];
        pbmVastCreativeNonLinearAdsNonLinear.identifier = attributeDict[@"id"];
        pbmVastCreativeNonLinearAdsNonLinear.width = [self parseInt: attributeDict[@"width"]];
        pbmVastCreativeNonLinearAdsNonLinear.height = [self parseInt: attributeDict[@"height"]];
        pbmVastCreativeNonLinearAdsNonLinear.assetWidth = [self parseInt: attributeDict[@"assetWidth"]];
        pbmVastCreativeNonLinearAdsNonLinear.assetHeight = [self parseInt: attributeDict[@"assetHeight"]];
        pbmVastCreativeNonLinearAdsNonLinear.scalable = [self parseBool: attributeDict[@"scalable"]];
        pbmVastCreativeNonLinearAdsNonLinear.maintainAspectRatio = [self parseBool: attributeDict[@"maintainAspectRatio"]];
        pbmVastCreativeNonLinearAdsNonLinear.minSuggestedDuration = [self parseTimeInterval: attributeDict[@"minSuggestedDuration"]];
        pbmVastCreativeNonLinearAdsNonLinear.apiFramework = attributeDict[@"apiFramework"];
        [pbmVastCreativeNonLinearAds.nonLinears addObject:pbmVastCreativeNonLinearAdsNonLinear];
    }
    else if ([elementName isEqualToString: @"Icon"]) {
        PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*) self.creative;
        if (!pbmVastCreativeLinear) {
            PBMLogError(@"Icon found, but current creative is not PBMVastCreativeLinear");
            return;
        }
        
        PBMVastIcon *icon = [PBMVastIcon new];
        icon.program = [self parseString: attributeDict[@"program"]];
        icon.width = [self parseInt: attributeDict[@"width"]];
        icon.height = [self parseInt: attributeDict[@"height"]];
        icon.xPosition = [self parseInt: attributeDict[@"xPosition"]];
        icon.yPosition = [self parseInt: attributeDict[@"yPosition"]];
        icon.duration = [self parseTimeInterval: attributeDict[@"duration"]];
        icon.startOffset = [self parseTimeInterval: attributeDict[@"startOffset"]];
        [pbmVastCreativeLinear.icons addObject: icon];
    }
    else if ([elementName isEqualToString: @"MediaFile"]) {
        PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*) self.creative;
        if (!pbmVastCreativeLinear) {
            PBMLogError(@"MediaFile found, but current creative is not PBMVastCreativeLinear");
            return;
        }
        
        PBMVastMediaFile *pbmVastMediaFile = [PBMVastMediaFile new];
        pbmVastMediaFile.id = attributeDict[@"id"];
        [pbmVastMediaFile setDeliver:attributeDict[@"delivery"]];
        pbmVastMediaFile.type = [self parseString: attributeDict[@"type"]];
        pbmVastMediaFile.width = [self parseInt: attributeDict[@"width"]];
        pbmVastMediaFile.height = [self parseInt: attributeDict[@"height"]];
        pbmVastMediaFile.codec = attributeDict[@"codec"];
        pbmVastMediaFile.apiFramework = attributeDict[@"apiFramework"];

        // After porting to Objective-C such casting will be omitted
        pbmVastMediaFile.bitrate = [NSNumber numberWithFloat:[self parseFloat:attributeDict[@"bitrate"]]];
        pbmVastMediaFile.minBitrate = [NSNumber numberWithFloat:[self parseFloat:attributeDict[@"minBitrate"]]];
        pbmVastMediaFile.maxBitrate = [NSNumber numberWithFloat:[self parseFloat:attributeDict[@"maxBitrate"]]];
        pbmVastMediaFile.scalable = [NSNumber numberWithBool:[self parseBool:attributeDict[@"scalable"]]];
        pbmVastMediaFile.maintainAspectRatio = [NSNumber numberWithBool:[self parseBool:attributeDict[@"maintainAspectRatio"]]];
        [pbmVastCreativeLinear.mediaFiles addObject:pbmVastMediaFile];
    }
    else if ([elementName isEqualToString: @"AdVerifications"]) {
        self.verificationParameter = [PBMVideoVerificationParameters new];
    }
    else if ([elementName isEqualToString: @"Verification"]) {
        self.verificationResource = [PBMVideoVerificationResource new];
        self.verificationResource.vendorKey = attributeDict[@"vendor"];
    }
    else if ([elementName isEqualToString: @"JavaScriptResource"]) {
        self.verificationResource.apiFramework = attributeDict[@"apiFramework"];
    }
    //Unsupported:
    //else if ([elementName isEqualToString: @"ExecutableResource"]) {
    //}
    //else if ([elementName isEqualToString: @"VerificationParameters"]) {
    //}
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString: @"Error"]) {
        if ([[self.elementPath subarrayWithRange:NSMakeRange(0, 2)] isEqual: @[@"VAST", @"Ad"]]) {
            [self.ad.errorURIs addObject:self.currentElementContent];
        }
        else if ([self.elementPath isEqual:@[@"VAST", @"Ad"]]) {
            self.parsedResponse.noAdsResponseURI = self.currentElementContent;
        }
    }
    else if ([elementName isEqualToString: @"AdSystem"]) {
        self.ad.adSystem = self.currentElementContent;
        self.ad.adSystemVersion = [self parseString: self.currentElementAttributes[@"version"]];
    }
    else if ([elementName isEqualToString: @"AdParameters"]) {
        self.creative.adParameters = self.currentElementContent;
    }
    else if ([elementName isEqualToString: @"AdTitle"]) {
        self.inlineAd.title = self.currentElementContent;
    }
    else if ([elementName isEqualToString: @"Advertiser"]) {
        self.inlineAd.advertiser = self.currentElementContent;
    }
    else if ([elementName isEqualToString: @"Impression"]) {
        [self.ad.impressionURIs addObject:self.currentElementContent];
    }
    else if ([elementName isEqualToString: @"Ad"]) {
        if (self.ad) {
            PBMVastAbstractAd *unwrappedAd = self.ad;
            unwrappedAd.identifier = [self parseString: self.adAttributes[@"id"]];
            
            if (self.adAttributes[@"sequence"]) {
                NSString *strSequence = self.adAttributes[@"sequence"];
                if (strSequence.intValue) {
                    unwrappedAd.sequence = strSequence.intValue;
                }
            }
            
            unwrappedAd.ownerResponse = self.parsedResponse;
            
            NSMutableArray *ads = [NSMutableArray arrayWithArray:self.parsedResponse.vastAbstractAds];
            [ads addObject:unwrappedAd];
            self.parsedResponse.vastAbstractAds = ads;
        }
        else {
            PBMLogError(@"Ad tag ending with no ad object.");
        }
        
        self.inlineAd = nil;
        self.wrapperAd = nil;
        self.ad = nil;
        self.adAttributes = nil;
    }
    else if ([elementName isEqualToString: @"Creative"]) {
        self.creative.identifier = self.creativeAttributes[@"id"];
        self.creative.adId = self.creativeAttributes[@"AdID"];
        
        if (self.creativeAttributes[@"sequence"]) {
            NSString *strSequence = self.creativeAttributes[@"sequence"];
            if (strSequence.intValue) {
                self.creative.sequence = strSequence.intValue;
            }
        }
        
        // doubleclick can produce empty Creative nodes
        if (self.creative) {
            [self.ad.creatives addObject:self.creative];
        }
        
        self.creative = nil;
        self.creativeAttributes = nil;
    }
    else if ([elementName isEqualToString: @"Tracking"]) {
        NSString *event = self.currentElementAttributes[@"event"];
        if (!event) {
            return;
        }
        
        PBMVastTrackingEvents *vastTrackingEvents = nil;
        
        if ([self.creative isKindOfClass: [PBMVastCreativeCompanionAds class]]) {
            PBMVastCreativeCompanionAds *pbmVastCreativeCompanionAds = (PBMVastCreativeCompanionAds*)self.creative;
            if (pbmVastCreativeCompanionAds.companions.count) {
                PBMVastCreativeCompanionAdsCompanion *companion = pbmVastCreativeCompanionAds.companions.lastObject;
                vastTrackingEvents = companion.trackingEvents;
            }
        }
        else if ([self.creative isKindOfClass: [PBMVastCreativeLinear class]]) {
            PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*)self.creative;
            vastTrackingEvents = pbmVastCreativeLinear.vastTrackingEvents;
        }
        else if ([self.creative isKindOfClass: [PBMVastCreativeNonLinearAds class]]) {
            PBMVastCreativeNonLinearAds *pbmVastCreativeNonLinearAds = (PBMVastCreativeNonLinearAds*)self.creative;
            if (pbmVastCreativeNonLinearAds.nonLinears.count) {
                PBMVastCreativeNonLinearAdsNonLinear *nonLinear = pbmVastCreativeNonLinearAds.nonLinears.lastObject;
                vastTrackingEvents = nonLinear.vastTrackingEvents;
            }
        }
        else if (self.verificationResource) {
            if (!self.verificationResource.trackingEvents) {
                self.verificationResource.trackingEvents = [PBMVastTrackingEvents new];
            }
            
            vastTrackingEvents = self.verificationResource.trackingEvents;
        }
        
        if (!vastTrackingEvents) {
            PBMLogError(@"No suitable tracking events object found to append contents of Tracking tag to");
            return;
        }
        
        [vastTrackingEvents addTrackingURL:self.currentElementContent event:event attributes:self.currentElementAttributes];
    }
    else if ([elementName isEqualToString: @"AdVerifications"]) {
        self.inlineAd.verificationParameters = self.verificationParameter;
        self.verificationParameter = nil;
    }
    else if ([elementName isEqualToString: @"Verification"]) {
        [self.verificationParameter.verificationResources addObject:self.verificationResource];
        self.verificationResource = nil;
    }
    else if ([elementName isEqualToString: @"JavaScriptResource"]) {
        self.verificationResource.url = self.currentElementContent;
    }
    // else if ([elementName isEqualToString: @"ExecutableResource"]) {
        // Unsuported
    // }
    else if ([elementName isEqualToString: @"VerificationParameters"]) {
        self.verificationResource.params = self.currentElementContent;
    }
    else if ([elementName isEqualToString: @"Duration"]) {
        PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*)self.creative;
        if (pbmVastCreativeLinear) {
            pbmVastCreativeLinear.duration = self.currentElementContent ? [self parseTimeInterval: self.currentElementContent] : 0;
        }
        else {
            PBMLogError(@"Duration tag found but creative not PBMVastCreativeLinear");
        }
    }
    else if ([elementName isEqualToString: @"ClickThrough"]) {
        PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*)self.creative;
        if (pbmVastCreativeLinear) {
            pbmVastCreativeLinear.clickThroughURI = self.currentElementContent;
        }
        else {
            PBMLogError(@"Clickthrough tag found but creative not PBMVastCreativeLinear");
        }
    }
    else if ([elementName isEqualToString: @"MediaFile"]) {
        PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*)self.creative;
        if (pbmVastCreativeLinear) {
            if (pbmVastCreativeLinear.mediaFiles.count) {
                PBMVastMediaFile *mediaFile = pbmVastCreativeLinear.mediaFiles.lastObject;
                mediaFile.mediaURI = self.currentElementContent;
            }
        }
        else {
            PBMLogError(@"MediaFile tag found but creative not PBMVastCreativeLinear");
        }
    }
    else if ([elementName isEqualToString: @"StaticResource"]) {
        [self parseResourceForType:PBMVastResourceTypeStaticResource];
    }
    else if ([elementName isEqualToString: @"IFrameResource"]) {
        [self parseResourceForType:PBMVastResourceTypeIFrameResource];
    }
    else if ([elementName isEqualToString: @"HTMLResource"]) {
        [self parseResourceForType:PBMVastResourceTypeHtmlResource];
    }
    else if ([elementName isEqualToString: @"ClickTracking"] || [elementName isEqualToString: @"CustomClick"]) {
        PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*)self.creative;
        if (!pbmVastCreativeLinear) {
            PBMLogError(@"%@ tag found but creative not PBMVastCreativeLinear", elementName);
            return;
        }
        [pbmVastCreativeLinear.clickTrackingURIs addObject:_currentElementContent];
    }
    else if ([elementName isEqualToString: @"IconClickThrough"]) {
        PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*)self.creative;
        if (!pbmVastCreativeLinear) {
            PBMLogError(@"IconClickThrough tag found but creative not PBMVastCreativeLinear");
            return;
        }
        
        if (pbmVastCreativeLinear.icons.count) {
            PBMVastIcon *icon = pbmVastCreativeLinear.icons.lastObject;
            icon.clickThroughURI = self.currentElementContent;
        }
    }
    else if ([elementName isEqualToString: @"IconClickTracking"]) {
        PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*)self.creative;
        if (!pbmVastCreativeLinear) {
            PBMLogError(@"IconClickTracking tag found but creative not PBMVastCreativeLinear");
            return;
        }
        
        if (pbmVastCreativeLinear.icons.count) {
            PBMVastIcon *icon = pbmVastCreativeLinear.icons.lastObject;
            [icon.clickTrackingURIs addObject:self.currentElementContent];
        }
    }
    else if ([elementName isEqualToString: @"IconViewTracking"]) {
        PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*)self.creative;
        if (!pbmVastCreativeLinear) {
            PBMLogError(@"IconViewTracking tag found but creative not PBMVastCreativeLinear");
            return;
        }
        
        if (pbmVastCreativeLinear.icons.count) {
            PBMVastIcon *icon = pbmVastCreativeLinear.icons.lastObject;
            icon.viewTrackingURI = self.currentElementContent;
        }
    }
    else if ([elementName isEqualToString: @"CompanionClickThrough"]) {
        PBMVastCreativeCompanionAds *pbmVastCreativeCompanionAds = (PBMVastCreativeCompanionAds*)self.creative;
        if (!pbmVastCreativeCompanionAds) {
            PBMLogError(@"CompanionClickThrough tag found but creative not PBMVastCreativeCompanionAds");
            return;
        }
        
        if (pbmVastCreativeCompanionAds.companions.count) {
            PBMVastCreativeCompanionAdsCompanion *companion = pbmVastCreativeCompanionAds.companions.lastObject;
            companion.clickThroughURI = self.currentElementContent;
        }
    }
    else if ([elementName isEqualToString: @"CompanionClickTracking"]) {
        PBMVastCreativeCompanionAds *pbmVastCreativeCompanionAds = (PBMVastCreativeCompanionAds*)self.creative;
        if (!pbmVastCreativeCompanionAds) {
            PBMLogError(@"CompanionClickTracking tag found but creative not PBMVastCreativeCompanionAds");
            return;
        }
        
        if (pbmVastCreativeCompanionAds.companions.count) {
            PBMVastCreativeCompanionAdsCompanion *companion = pbmVastCreativeCompanionAds.companions.lastObject;
            [companion.clickTrackingURIs addObject:self.currentElementContent];
        }
    }
    else if ([elementName isEqualToString: @"NonLinearClickThrough"]) {
        PBMVastCreativeNonLinearAds *pbmVastCreativeNonLinearAds = (PBMVastCreativeNonLinearAds*)self.creative;
        if (!pbmVastCreativeNonLinearAds) {
            PBMLogError(@"NonLinearClickThrough tag found but creative not PBMVastCreativeNonLinearAds");
            return;
        }
        
        if (pbmVastCreativeNonLinearAds.nonLinears.count) {
            PBMVastCreativeNonLinearAdsNonLinear *pbmVastCreativeNonLinearAdsNonLinear = pbmVastCreativeNonLinearAds.nonLinears.lastObject;
            pbmVastCreativeNonLinearAdsNonLinear.clickThroughURI = self.currentElementContent;
        }
        else {
            PBMLogError(@"NonLinearClickThrough tag found but no NonLinear objects to append content to");
        }
    }
    else if ([elementName isEqualToString: @"NonLinearClickTracking"]) {
        PBMVastCreativeNonLinearAds *pbmVastCreativeNonLinearAds = (PBMVastCreativeNonLinearAds*)self.creative;
        if (!pbmVastCreativeNonLinearAds) {
            PBMLogError(@"NonLinearClickTracking tag found but creative not PBMVastCreativeNonLinearAds");
            return;
        }
        
        if (pbmVastCreativeNonLinearAds.nonLinears.count) {
            PBMVastCreativeNonLinearAdsNonLinear *pbmVastCreativeNonLinearAdsNonLinear = pbmVastCreativeNonLinearAds.nonLinears.lastObject;
            [pbmVastCreativeNonLinearAdsNonLinear.clickTrackingURIs addObject:self.currentElementContent];
        }
        else {
            PBMLogError(@"NonLinearClickTracking tag found but no NonLinear objects to append content to");
        }
    }
    else if ([elementName isEqualToString: @"VASTAdTagURI"]) {
        self.wrapperAd.vastURI = self.currentElementContent;
    }
    
    if (self.elementPath.count > 0) {
        [self.elementPath removeLastObject];
    }
    else {
        PBMLogError(@"elementPath unexpectedly empty");
    }
    
    self.currentElementAttributes = nil;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.currentElementContent = [self.currentElementContent stringByAppendingString: trimmedString];
}

-(void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    // this reports a CDATA block to the delegate as an NSData.
    NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    if (!string) {
        return;
    }
    
    //Trim CDATA Blocks. Normally you don't alter CDATA blocks at all, but we're getting URLs
    //padded with whitespace inside of CDATA blocks.
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.currentElementContent = [self.currentElementContent stringByAppendingString: trimmedString];
}

#pragma mark - Helper Methods

- (id <PBMVastResourceContainerProtocol>)extractCreativeContainer {
    id <PBMVastResourceContainerProtocol> container = nil;
    
    if ([self.creative isKindOfClass: [PBMVastCreativeLinear class]]) {
        PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*)self.creative;
        if ([pbmVastCreativeLinear.icons.lastObject isKindOfClass:[PBMVastIcon class]]) {
            container = pbmVastCreativeLinear.icons.lastObject;
        }
    }
    else if ([self.creative isKindOfClass: [PBMVastCreativeCompanionAds class]]) {
        PBMVastCreativeCompanionAds *pbmVastCreativeCompanionAds = (PBMVastCreativeCompanionAds*)self.creative;
        if ([pbmVastCreativeCompanionAds.companions.lastObject isKindOfClass:[PBMVastCreativeCompanionAdsCompanion class]]) {
            container = pbmVastCreativeCompanionAds.companions.lastObject;
        }
    }
    else if ([self.creative isKindOfClass: [PBMVastCreativeNonLinearAds class]]) {
        PBMVastCreativeNonLinearAds *pbmVastNonLinearCreative = (PBMVastCreativeNonLinearAds*)self.creative;
        if ([pbmVastNonLinearCreative.nonLinears.lastObject isKindOfClass:[PBMVastCreativeNonLinearAdsNonLinear class]]) {
            container = pbmVastNonLinearCreative.nonLinears.lastObject;
        }
    }
    
    return container;
}

@end
