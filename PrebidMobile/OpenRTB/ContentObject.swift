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

import Foundation

@objc(PBAdUnitContentObject)
@objcMembers
public class ContentObject: NSObject, JSONConvertible {
    ///ID uniquely identifying the content.
    public var id: String?
    ///Episode number.
    public var episode: Int?
    ///Content title.
    public var title: String?
    ///Content series.
    public var series: String?
    ///Content season.
    public var season: String?
    ///Artist credited with the content.
    public var artist: String?
    ///Genre that best describes the content.
    public var genre: String?
    ///Album to which the content belongs; typically for audio.
    public var album: String?
    ///International Standard Recording Code conforming to ISO- 3901.
    public var isrc: String?
    ///This object defines the producer of the content in which the ad will be shown.
    public var producer: ContentProducerObject?
    ///URL of the content, for buy-side contextualization or review.
    public var url: String?
    ///Array of IAB content categories that describe the content producer.
    public var cat: [String]?
    ///Production quality.
    public var prodq: Int?
    ///Type of content (game, video, text, etc.).
    public var context: Int?
    ///Content rating (e.g., MPAA).
    public var contentrating: String?
    ///User rating of the content (e.g., number of stars, likes, etc.).
    public var userrating: String?
    ///Media rating per IQG guidelines.
    public var qagmediarating: Int?
    ///Comma separated list of keywords describing the content.
    public var keywords: String?
    ///0 = not live, 1 = content is live (e.g., stream, live blog).
    public var livestream: Int?
    ///0 = indirect, 1 = direct.
    public var sourcerelationship: Int?
    ///Length of content in seconds; appropriate for video or audio.
    public var len: Int?
    ///Content language using ISO-639-1-alpha-2.
    public var language: String?
    ///Indicator of whether or not the content is embeddable (e.g., an embeddable video player), where 0 = no, 1 = yes.
    public var embeddable: Int?
    ///Additional content data.
    public var data: [ContentDataObject]?
    
    public func toJSONDictionary() -> [AnyHashable: Any] {
        var content = [AnyHashable: Any]()
        
        if let url = url, !url.isEmpty {
            content["url"] = url
        }
        content["id"] = id
        content["episode"] = episode
        content["title"] = title
        content["series"] = series
        content["season"] = season
        content["artist"] = artist
        content["genre"] = genre
        content["album"] = album
        content["isrc"] = isrc
        
        if let producer = producer {
            content["producer"] = producer.toJSONDictionary()
        }
        
        content["cat"] = cat
        content["prodq"] = prodq
        content["context"] = context
        content["contentrating"] = contentrating
        content["userrating"] = userrating
        content["qagmediarating"] = qagmediarating
        content["keywords"] = keywords
        content["livestream"] = livestream
        content["sourcerelationship"] = sourcerelationship
        content["len"] = len
        content["language"] = language
        content["embeddable"] = embeddable
       
        if let data = data {
            var dataArray: [[AnyHashable: Any]] = []
            
            data.forEach({
                dataArray += [$0.toJSONDictionary()]
            })

            content["data"] = dataArray
        }
        
        return content
    }
}
