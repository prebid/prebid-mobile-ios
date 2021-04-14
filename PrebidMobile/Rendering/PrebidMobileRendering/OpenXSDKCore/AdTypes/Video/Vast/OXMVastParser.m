//
//  OXMVastParser.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastParser.h"

#import "OXMLog.h"
#import "OXMVastGlobals.h"
#import "OXMVastResponse.h"
#import "OXMVastInlineAd.h"
#import "OXMVastWrapperAd.h"
#import "OXMVastAbstractAd.h"
#import "OXMVastCreativeLinear.h"
#import "OXMVastCreativeNonLinearAds.h"
#import "OXMVastCreativeCompanionAds.h"
#import "OXMVastResourceContainerProtocol.h"
#import "OXMVastIcon.h"
#import "OXMVastCreativeCompanionAdsCompanion.h"
#import "OXMVastCreativeNonLinearAdsNonLinear.h"

#import "OXMVideoVerificationParameters.h"

@interface OXMVastParser ()

@property (nonatomic, assign) BOOL parseSuccessful;

@end

@implementation OXMVastParser

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

- (OXMVastResponse *)parseAdsResponse:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    
    self.currentElementContext = @"";
    self.elementPath = [NSMutableArray array];
    [parser parse];
    
    return self.parseSuccessful ? self.parsedResponse : nil;
}

//The Companion, and NonLinear and Icon tags can all have StaticResource, IFrameResource and
//HTMLResource tag children. To represent this, the OXMVastIcon,
//OXMVastCreativeCompanionAdsCompanion, and OXMVastCreativeNonLinearAdsNonLinear classes
//all conform to OXMVastResourceContainer.
-(void)parseResourceForType:(OXMVastResourceType)type {
    
    if (!self.creative) {
        OXMLogError(@"No applicable creative");
        return;
    }
    
    id <OXMVastResourceContainerProtocol> container = [self extractCreativeContainer];

    //Bail if unsuccessful
    if (!container) {
        OXMLogError(@"No applicable container to apply currentElementContent of [%@] to. Type is %ld.",
                    self.currentElementContent, (long)type);
        return;
    }
    
    //Fill out OXMVastResourceContainer fields
    container.resourceType = type;
    container.resource = self.currentElementContent;
    if (type == OXMVastResourceTypeStaticResource) {
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
                OXMLogError(@"Unable to parse time string: %@", str);
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
    self.parsedResponse = [OXMVastResponse new];
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
        self.inlineAd = [OXMVastInlineAd new];
        self.ad = self.inlineAd;
    }
    else if ([elementName isEqualToString: @"Wrapper"]) {
        
        OXMVastWrapperAd *oxmWrapperAd = [OXMVastWrapperAd new];
        
        id followAdditionalWrappersKey = attributeDict[@"followAdditionalWrappers"];
        if (followAdditionalWrappersKey) {
            oxmWrapperAd.followAdditionalWrappers = [self parseBool:followAdditionalWrappersKey];
        }
        
        id allowMultipleAdsKey = attributeDict[@"allowMultipleAds"];
        if (allowMultipleAdsKey) {
            oxmWrapperAd.allowMultipleAds = [self parseBool:allowMultipleAdsKey];
        }
        
        id fallbackOnNoAdKey = attributeDict[@"fallbackOnNoAd"];
        if (fallbackOnNoAdKey) {
            oxmWrapperAd.fallbackOnNoAd = [self parseBool:fallbackOnNoAdKey];
        }
        
        self.wrapperAd = oxmWrapperAd;
        self.ad = oxmWrapperAd;
    }
    else if ([elementName isEqualToString: @"Creative"]) {
        self.creativeAttributes = attributeDict;
    }
    else if ([elementName isEqualToString: @"Linear"]) {
        OXMVastCreativeLinear *creative = [OXMVastCreativeLinear new];
        creative.skipOffset = [self parseSkipOffset:attributeDict[@"skipoffset"]];
        self.creative = creative;
    }
    else if ([elementName isEqualToString: @"CompanionAds"]) {
        OXMVastCreativeCompanionAds *creative = [OXMVastCreativeCompanionAds new];
        creative.requiredMode = [self parseString:attributeDict[@"required"]];
        self.creative = creative;
    }
    else if ([elementName isEqualToString: @"Companion"]) {
        OXMVastCreativeCompanionAds *oxmVastCreativeCompanionAds = (OXMVastCreativeCompanionAds*) self.creative;
        if (!oxmVastCreativeCompanionAds) {
            OXMLogError(@"Error - expected current creative to be OXMVastCreativeCompanionAds");
            return;
        }
        
        OXMVastCreativeCompanionAdsCompanion *companion = [OXMVastCreativeCompanionAdsCompanion new];
        companion.companionIdentifier = attributeDict[@"id"];
        companion.width = [self parseInt: attributeDict[@"width"]];
        companion.height = [self parseInt: attributeDict[@"height"]];
        companion.assetWidth = [self parseInt: attributeDict[@"assetWidth"]];
        companion.assetHeight = [self parseInt: attributeDict[@"assetHeight"]];
        [oxmVastCreativeCompanionAds.companions addObject:companion];
    }
    else if ([elementName isEqualToString: @"NonLinearAds"]) {
        self.creative = [OXMVastCreativeNonLinearAds new];
    }
    else if ([elementName isEqualToString: @"NonLinear"]) {
        OXMVastCreativeNonLinearAds *oxmVastCreativeNonLinearAds = (OXMVastCreativeNonLinearAds*) self.creative;
        if (!oxmVastCreativeNonLinearAds) {
            OXMLogError(@"Expected current creative to be OXMVastCreativeNonLinearAds");
            return;
        }
        
        OXMVastCreativeNonLinearAdsNonLinear *oxmVastCreativeNonLinearAdsNonLinear = [OXMVastCreativeNonLinearAdsNonLinear new];
        oxmVastCreativeNonLinearAdsNonLinear.identifier = attributeDict[@"id"];
        oxmVastCreativeNonLinearAdsNonLinear.width = [self parseInt: attributeDict[@"width"]];
        oxmVastCreativeNonLinearAdsNonLinear.height = [self parseInt: attributeDict[@"height"]];
        oxmVastCreativeNonLinearAdsNonLinear.assetWidth = [self parseInt: attributeDict[@"assetWidth"]];
        oxmVastCreativeNonLinearAdsNonLinear.assetHeight = [self parseInt: attributeDict[@"assetHeight"]];
        oxmVastCreativeNonLinearAdsNonLinear.scalable = [self parseBool: attributeDict[@"scalable"]];
        oxmVastCreativeNonLinearAdsNonLinear.maintainAspectRatio = [self parseBool: attributeDict[@"maintainAspectRatio"]];
        oxmVastCreativeNonLinearAdsNonLinear.minSuggestedDuration = [self parseTimeInterval: attributeDict[@"minSuggestedDuration"]];
        oxmVastCreativeNonLinearAdsNonLinear.apiFramework = attributeDict[@"apiFramework"];
        [oxmVastCreativeNonLinearAds.nonLinears addObject:oxmVastCreativeNonLinearAdsNonLinear];
    }
    else if ([elementName isEqualToString: @"Icon"]) {
        OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*) self.creative;
        if (!oxmVastCreativeLinear) {
            OXMLogError(@"Icon found, but current creative is not OXMVastCreativeLinear");
            return;
        }
        
        OXMVastIcon *icon = [OXMVastIcon new];
        icon.program = [self parseString: attributeDict[@"program"]];
        icon.width = [self parseInt: attributeDict[@"width"]];
        icon.height = [self parseInt: attributeDict[@"height"]];
        icon.xPosition = [self parseInt: attributeDict[@"xPosition"]];
        icon.yPosition = [self parseInt: attributeDict[@"yPosition"]];
        icon.duration = [self parseTimeInterval: attributeDict[@"duration"]];
        icon.startOffset = [self parseTimeInterval: attributeDict[@"startOffset"]];
        [oxmVastCreativeLinear.icons addObject: icon];
    }
    else if ([elementName isEqualToString: @"MediaFile"]) {
        OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*) self.creative;
        if (!oxmVastCreativeLinear) {
            OXMLogError(@"MediaFile found, but current creative is not OXMVastCreativeLinear");
            return;
        }
        
        OXMVastMediaFile *oxmVastMediaFile = [OXMVastMediaFile new];
        oxmVastMediaFile.id = attributeDict[@"id"];
        [oxmVastMediaFile setDeliver:attributeDict[@"delivery"]];
        oxmVastMediaFile.type = [self parseString: attributeDict[@"type"]];
        oxmVastMediaFile.width = [self parseInt: attributeDict[@"width"]];
        oxmVastMediaFile.height = [self parseInt: attributeDict[@"height"]];
        oxmVastMediaFile.codec = attributeDict[@"codec"];
        oxmVastMediaFile.apiFramework = attributeDict[@"apiFramework"];

        // After porting to Objective-C such casting will be omitted
        oxmVastMediaFile.bitrate = [NSNumber numberWithFloat:[self parseFloat:attributeDict[@"bitrate"]]];
        oxmVastMediaFile.minBitrate = [NSNumber numberWithFloat:[self parseFloat:attributeDict[@"minBitrate"]]];
        oxmVastMediaFile.maxBitrate = [NSNumber numberWithFloat:[self parseFloat:attributeDict[@"maxBitrate"]]];
        oxmVastMediaFile.scalable = [NSNumber numberWithBool:[self parseBool:attributeDict[@"scalable"]]];
        oxmVastMediaFile.maintainAspectRatio = [NSNumber numberWithBool:[self parseBool:attributeDict[@"maintainAspectRatio"]]];
        [oxmVastCreativeLinear.mediaFiles addObject:oxmVastMediaFile];
    }
    else if ([elementName isEqualToString: @"AdVerifications"]) {
        self.verificationParameter = [OXMVideoVerificationParameters new];
    }
    else if ([elementName isEqualToString: @"Verification"]) {
        self.verificationResource = [OXMVideoVerificationResource new];
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
            OXMVastAbstractAd *unwrappedAd = self.ad;
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
            OXMLogError(@"Ad tag ending with no ad object.");
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
        
        OXMVastTrackingEvents *vastTrackingEvents = nil;
        
        if ([self.creative isKindOfClass: [OXMVastCreativeCompanionAds class]]) {
            OXMVastCreativeCompanionAds *oxmVastCreativeCompanionAds = (OXMVastCreativeCompanionAds*)self.creative;
            if (oxmVastCreativeCompanionAds.companions.count) {
                OXMVastCreativeCompanionAdsCompanion *companion = oxmVastCreativeCompanionAds.companions.lastObject;
                vastTrackingEvents = companion.trackingEvents;
            }
        }
        else if ([self.creative isKindOfClass: [OXMVastCreativeLinear class]]) {
            OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*)self.creative;
            vastTrackingEvents = oxmVastCreativeLinear.vastTrackingEvents;
        }
        else if ([self.creative isKindOfClass: [OXMVastCreativeNonLinearAds class]]) {
            OXMVastCreativeNonLinearAds *oxmVastCreativeNonLinearAds = (OXMVastCreativeNonLinearAds*)self.creative;
            if (oxmVastCreativeNonLinearAds.nonLinears.count) {
                OXMVastCreativeNonLinearAdsNonLinear *nonLinear = oxmVastCreativeNonLinearAds.nonLinears.lastObject;
                vastTrackingEvents = nonLinear.vastTrackingEvents;
            }
        }
        else if (self.verificationResource) {
            if (!self.verificationResource.trackingEvents) {
                self.verificationResource.trackingEvents = [OXMVastTrackingEvents new];
            }
            
            vastTrackingEvents = self.verificationResource.trackingEvents;
        }
        
        if (!vastTrackingEvents) {
            OXMLogError(@"No suitable tracking events object found to append contents of Tracking tag to");
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
        OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*)self.creative;
        if (oxmVastCreativeLinear) {
            oxmVastCreativeLinear.duration = self.currentElementContent ? [self parseTimeInterval: self.currentElementContent] : 0;
        }
        else {
            OXMLogError(@"Duration tag found but creative not OXMVastCreativeLinear");
        }
    }
    else if ([elementName isEqualToString: @"ClickThrough"]) {
        OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*)self.creative;
        if (oxmVastCreativeLinear) {
            oxmVastCreativeLinear.clickThroughURI = self.currentElementContent;
        }
        else {
            OXMLogError(@"Clickthrough tag found but creative not OXMVastCreativeLinear");
        }
    }
    else if ([elementName isEqualToString: @"MediaFile"]) {
        OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*)self.creative;
        if (oxmVastCreativeLinear) {
            if (oxmVastCreativeLinear.mediaFiles.count) {
                OXMVastMediaFile *mediaFile = oxmVastCreativeLinear.mediaFiles.lastObject;
                mediaFile.mediaURI = self.currentElementContent;
            }
        }
        else {
            OXMLogError(@"MediaFile tag found but creative not OXMVastCreativeLinear");
        }
    }
    else if ([elementName isEqualToString: @"StaticResource"]) {
        [self parseResourceForType:OXMVastResourceTypeStaticResource];
    }
    else if ([elementName isEqualToString: @"IFrameResource"]) {
        [self parseResourceForType:OXMVastResourceTypeIFrameResource];
    }
    else if ([elementName isEqualToString: @"HTMLResource"]) {
        [self parseResourceForType:OXMVastResourceTypeHtmlResource];
    }
    else if ([elementName isEqualToString: @"ClickTracking"] || [elementName isEqualToString: @"CustomClick"]) {
        OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*)self.creative;
        if (!oxmVastCreativeLinear) {
            OXMLogError(@"%@ tag found but creative not OXMVastCreativeLinear", elementName);
            return;
        }
        [oxmVastCreativeLinear.clickTrackingURIs addObject:_currentElementContent];
    }
    else if ([elementName isEqualToString: @"IconClickThrough"]) {
        OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*)self.creative;
        if (!oxmVastCreativeLinear) {
            OXMLogError(@"IconClickThrough tag found but creative not OXMVastCreativeLinear");
            return;
        }
        
        if (oxmVastCreativeLinear.icons.count) {
            OXMVastIcon *icon = oxmVastCreativeLinear.icons.lastObject;
            icon.clickThroughURI = self.currentElementContent;
        }
    }
    else if ([elementName isEqualToString: @"IconClickTracking"]) {
        OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*)self.creative;
        if (!oxmVastCreativeLinear) {
            OXMLogError(@"IconClickTracking tag found but creative not OXMVastCreativeLinear");
            return;
        }
        
        if (oxmVastCreativeLinear.icons.count) {
            OXMVastIcon *icon = oxmVastCreativeLinear.icons.lastObject;
            [icon.clickTrackingURIs addObject:self.currentElementContent];
        }
    }
    else if ([elementName isEqualToString: @"IconViewTracking"]) {
        OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*)self.creative;
        if (!oxmVastCreativeLinear) {
            OXMLogError(@"IconViewTracking tag found but creative not OXMVastCreativeLinear");
            return;
        }
        
        if (oxmVastCreativeLinear.icons.count) {
            OXMVastIcon *icon = oxmVastCreativeLinear.icons.lastObject;
            icon.viewTrackingURI = self.currentElementContent;
        }
    }
    else if ([elementName isEqualToString: @"CompanionClickThrough"]) {
        OXMVastCreativeCompanionAds *oxmVastCreativeCompanionAds = (OXMVastCreativeCompanionAds*)self.creative;
        if (!oxmVastCreativeCompanionAds) {
            OXMLogError(@"CompanionClickThrough tag found but creative not OXMVastCreativeCompanionAds");
            return;
        }
        
        if (oxmVastCreativeCompanionAds.companions.count) {
            OXMVastCreativeCompanionAdsCompanion *companion = oxmVastCreativeCompanionAds.companions.lastObject;
            companion.clickThroughURI = self.currentElementContent;
        }
    }
    else if ([elementName isEqualToString: @"CompanionClickTracking"]) {
        OXMVastCreativeCompanionAds *oxmVastCreativeCompanionAds = (OXMVastCreativeCompanionAds*)self.creative;
        if (!oxmVastCreativeCompanionAds) {
            OXMLogError(@"CompanionClickTracking tag found but creative not OXMVastCreativeCompanionAds");
            return;
        }
        
        if (oxmVastCreativeCompanionAds.companions.count) {
            OXMVastCreativeCompanionAdsCompanion *companion = oxmVastCreativeCompanionAds.companions.lastObject;
            [companion.clickTrackingURIs addObject:self.currentElementContent];
        }
    }
    else if ([elementName isEqualToString: @"NonLinearClickThrough"]) {
        OXMVastCreativeNonLinearAds *oxmVastCreativeNonLinearAds = (OXMVastCreativeNonLinearAds*)self.creative;
        if (!oxmVastCreativeNonLinearAds) {
            OXMLogError(@"NonLinearClickThrough tag found but creative not OXMVastCreativeNonLinearAds");
            return;
        }
        
        if (oxmVastCreativeNonLinearAds.nonLinears.count) {
            OXMVastCreativeNonLinearAdsNonLinear *oxmVastCreativeNonLinearAdsNonLinear = oxmVastCreativeNonLinearAds.nonLinears.lastObject;
            oxmVastCreativeNonLinearAdsNonLinear.clickThroughURI = self.currentElementContent;
        }
        else {
            OXMLogError(@"NonLinearClickThrough tag found but no NonLinear objects to append content to");
        }
    }
    else if ([elementName isEqualToString: @"NonLinearClickTracking"]) {
        OXMVastCreativeNonLinearAds *oxmVastCreativeNonLinearAds = (OXMVastCreativeNonLinearAds*)self.creative;
        if (!oxmVastCreativeNonLinearAds) {
            OXMLogError(@"NonLinearClickTracking tag found but creative not OXMVastCreativeNonLinearAds");
            return;
        }
        
        if (oxmVastCreativeNonLinearAds.nonLinears.count) {
            OXMVastCreativeNonLinearAdsNonLinear *oxmVastCreativeNonLinearAdsNonLinear = oxmVastCreativeNonLinearAds.nonLinears.lastObject;
            [oxmVastCreativeNonLinearAdsNonLinear.clickTrackingURIs addObject:self.currentElementContent];
        }
        else {
            OXMLogError(@"NonLinearClickTracking tag found but no NonLinear objects to append content to");
        }
    }
    else if ([elementName isEqualToString: @"VASTAdTagURI"]) {
        self.wrapperAd.vastURI = self.currentElementContent;
    }
    
    if (self.elementPath.count > 0) {
        [self.elementPath removeLastObject];
    }
    else {
        OXMLogError(@"elementPath unexpectedly empty");
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

- (id <OXMVastResourceContainerProtocol>)extractCreativeContainer {
    id <OXMVastResourceContainerProtocol> container = nil;
    
    if ([self.creative isKindOfClass: [OXMVastCreativeLinear class]]) {
        OXMVastCreativeLinear *oxmVastCreativeLinear = (OXMVastCreativeLinear*)self.creative;
        if ([oxmVastCreativeLinear.icons.lastObject isKindOfClass:[OXMVastIcon class]]) {
            container = oxmVastCreativeLinear.icons.lastObject;
        }
    }
    else if ([self.creative isKindOfClass: [OXMVastCreativeCompanionAds class]]) {
        OXMVastCreativeCompanionAds *oxmVastCreativeCompanionAds = (OXMVastCreativeCompanionAds*)self.creative;
        if ([oxmVastCreativeCompanionAds.companions.lastObject isKindOfClass:[OXMVastCreativeCompanionAdsCompanion class]]) {
            container = oxmVastCreativeCompanionAds.companions.lastObject;
        }
    }
    else if ([self.creative isKindOfClass: [OXMVastCreativeNonLinearAds class]]) {
        OXMVastCreativeNonLinearAds *oxmVastNonLinearCreative = (OXMVastCreativeNonLinearAds*)self.creative;
        if ([oxmVastNonLinearCreative.nonLinears.lastObject isKindOfClass:[OXMVastCreativeNonLinearAdsNonLinear class]]) {
            container = oxmVastNonLinearCreative.nonLinears.lastObject;
        }
    }
    
    return container;
}

@end
