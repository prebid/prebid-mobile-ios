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


#import "PBMORTBAppContent.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBContentProducer.h"
#import "PBMORTBContentData.h"

@implementation PBMORTBAppContent : PBMORTBAbstract

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"id"] = self.id;
    ret[@"episode"] = self.episode;
    ret[@"title"] = self.title;
    ret[@"series"] = self.series;
    ret[@"season"] = self.season;
    ret[@"artist"] = self.artist;
    ret[@"genre"] = self.genre;
    ret[@"album"] = self.album;
    ret[@"isrc"] = self.isrc;
    
    if(self.producer) {
        ret[@"producer"] = [self.producer toJsonDictionary];;
    }
    
    ret[@"url"] = self.url;
    ret[@"cat"] = self.cat;
    ret[@"prodq"] = self.prodq;
    ret[@"context"] = self.context;
    ret[@"contentrating"] = self.contentrating;
    ret[@"userrating"] = self.userrating;
    ret[@"qagmediarating"] = self.qagmediarating;
    ret[@"keywords"] = self.keywords;
    ret[@"livestream"] = self.livestream;
    ret[@"sourcerelationship"] = self.sourcerelationship;
    ret[@"len"] = self.len;
    ret[@"language"] = self.language;
    ret[@"embeddable"] = self.embeddable;
    
    if(self.data) {
        NSMutableArray<PBMJsonDictionary *> *dataArray = [NSMutableArray<PBMJsonDictionary *> new];
        for (PBMORTBContentData *dataObject in self.data) {
            [dataArray addObject:[dataObject toJsonDictionary]];
        }
        
        ret[@"data"] = dataArray;
    }
    
    if (self.ext && self.ext.count) {
        ret[@"ext"] = self.ext;
    }
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    
    _id = jsonDictionary[@"id"];
    _episode = jsonDictionary[@"episode"];
    _title = jsonDictionary[@"title"];
    _series = jsonDictionary[@"series"];
    _season = jsonDictionary[@"season"];
    _artist = jsonDictionary[@"artist"];
    _genre = jsonDictionary[@"genre"];
    _album = jsonDictionary[@"album"];
    _isrc = jsonDictionary[@"isrc"];
    
    PBMORTBContentProducer *producerJsonDictionary = jsonDictionary[@"producer"];
    if (producerJsonDictionary) {
        _producer = [[PBMORTBContentProducer alloc] initWithJsonDictionary:jsonDictionary[@"producer"]];
    }
    
    _url = jsonDictionary[@"url"];
    _cat = jsonDictionary[@"cat"];
    _prodq = jsonDictionary[@"prodq"];
    _context = jsonDictionary[@"context"];
    _contentrating = jsonDictionary[@"contentrating"];
    _userrating = jsonDictionary[@"userrating"];
    _qagmediarating = jsonDictionary[@"qagmediarating"];
    _keywords = jsonDictionary[@"keywords"];
    _livestream = jsonDictionary[@"livestream"];
    _sourcerelationship = jsonDictionary[@"sourcerelationship"];
    _len = jsonDictionary[@"len"];
    _language = jsonDictionary[@"language"];
    _embeddable = jsonDictionary[@"embeddable"];
    
    NSMutableArray<PBMORTBContentData *> *dataArray = [NSMutableArray<PBMORTBContentData *> new];
    NSMutableArray<PBMJsonDictionary *> *dataDicts = jsonDictionary[@"data"];
    if (dataDicts.count > 0) {
        for (PBMJsonDictionary *dataDict in dataDicts) {
            if (dataDict && [dataDict isKindOfClass:[NSDictionary class]])
                [dataArray addObject:[[PBMORTBContentData alloc] initWithJsonDictionary:dataDict]];
        }
        
        _data = dataArray;
    }
    
    _ext = jsonDictionary[@"ext"];
  
    return self;
}

@end
