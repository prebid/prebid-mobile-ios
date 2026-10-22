//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

class ORTBAppContent: NSObject, PBMJsonCodable {
    
    /// ID uniquely identifying the content.
    var id: String?
    
    /// Episode number.
    var episode: NSNumber?
    
    /// Content title.
    var title: String?
    
    /// Content series.
    var series: String?
    
    /// Content season.
    var season: String?
    
    /// Artist credited with the content.
    var artist: String?
    
    /// Genre that best describes the content.
    var genre: String?
    
    /// Album to which the content belongs; typically for audio.
    var album: String?
    
    /// International Standard Recording Code conforming to ISO-3901.
    var isrc: String?
    
    /// This object defines the producer of the content in which the ad will be shown.
    var producer: ORTBContentProducer?
    
    /// URL of the content, for buy-side contextualization or review.
    var url: String?
    
    /// Array of IAB content categories that describe the content producer.
    var cat: [String]?
    
    /// Production quality.
    var prodq: NSNumber?
    
    /// Type of content (game, video, text, etc.).
    var context: NSNumber?
    
    /// Content rating.
    var contentrating: String?
    
    /// User rating of the content.
    var userrating: String?
    
    /// Media rating per IQG guidelines.
    var qagmediarating: NSNumber?
    
    /// Comma separated list of keywords describing the content.
    var keywords: String?
    
    /// 0 = not live, 1 = content is live.
    var livestream: NSNumber?
    
    /// 0 = indirect, 1 = direct.
    var sourcerelationship: NSNumber?
    
    /// Length of content in seconds; appropriate for video or audio.
    var len: NSNumber?
    
    /// Content language using ISO-639-1-alpha-2.
    var language: String?
    
    /// Indicator of whether or not the content is embeddable (e.g., an embeddable video player), where 0 = no, 1 = yes.
    var embeddable: NSNumber?
    
    /// The data and segment objects together allow additional data about the related object (e.g., user, content) to be specified.
    var data: [ORTBContentData]?
    
    /// Placeholder for exchange-specific extensions to OpenRTB.
    var ext: [String: Any]?
    
    private enum KeySet: String {
        case id
        case episode
        case title
        case series
        case season
        case artist
        case genre
        case album
        case isrc
        case producer
        case url
        case cat
        case prodq
        case context
        case contentrating
        case userrating
        case qagmediarating
        case keywords
        case livestream
        case sourcerelationship
        case len
        case language
        case embeddable
        case data
        case ext
    }
    
    override init() {
        super.init()
    }

    required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        id                  = json[.id]
        episode             = json[.episode]
        title               = json[.title]
        series              = json[.series]
        season              = json[.season]
        artist              = json[.artist]
        genre               = json[.genre]
        album               = json[.album]
        isrc                = json[.isrc]
        producer            = json[.producer]
        url                 = json[.url]
        cat                 = json[.cat]
        prodq               = json[.prodq]
        context             = json[.context]
        contentrating       = json[.contentrating]
        userrating          = json[.userrating]
        qagmediarating      = json[.qagmediarating]
        keywords            = json[.keywords]
        livestream          = json[.livestream]
        sourcerelationship  = json[.sourcerelationship]
        len                 = json[.len]
        language            = json[.language]
        embeddable          = json[.embeddable]
        data                = json[.data]
        ext                 = json[.ext]
    }

    var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.id]                   = id
        json[.episode]              = episode
        json[.title]                = title
        json[.series]               = series
        json[.season]               = season
        json[.artist]               = artist
        json[.genre]                = genre
        json[.album]                = album
        json[.isrc]                 = isrc
        json[.producer]             = producer
        json[.url]                  = url
        json[.cat]                  = cat
        json[.prodq]                = prodq
        json[.context]              = context
        json[.contentrating]        = contentrating
        json[.userrating]           = userrating
        json[.qagmediarating]       = qagmediarating
        json[.keywords]             = keywords
        json[.livestream]           = livestream
        json[.sourcerelationship]   = sourcerelationship
        json[.len]                  = len
        json[.language]             = language
        json[.embeddable]           = embeddable
        json[.data]                 = data
        json[.ext]                  = ext

        return json.dict
    }
}
