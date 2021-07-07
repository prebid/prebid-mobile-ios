//
//  ImageCreativeData.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation


@objc(MPImageCreativeData)
public class ImageCreativeData: NSObject {
    
    /// Converts server response data into this model class
    /// Returns `nil` if `imageURL` is missing from the server response.
    @objc public required init?(withServerResponseData serverResponseData: Data?) {
        guard let serverResponseData = serverResponseData,
              let decodedResponse = try? JSONDecoder().decode(ImageCreativeDataStruct.self, from: serverResponseData) else {
            return nil
        }
        
        decodedServerResponse = decodedResponse
        
        super.init()
    }
    
    /// The decoded image URL
    @objc public var imageURL: URL {
        get {
            return decodedServerResponse.imageURL
        }
    }
    
    /// The decoded clickthrough URL, if available
    @objc public var clickthroughURL: URL? {
        get {
            return decodedServerResponse.clickthroughURL
        }
    }
    
    /// Instance of the codable struct type for ImageCreativeData
    private let decodedServerResponse: ImageCreativeDataStruct
    
    /// Backing codable struct type for ImageCreativeData
    private struct ImageCreativeDataStruct: Codable {
        /// Stores the URL to access the image ad to be rendered
        let imageURL: URL
        
        /// Stores the clickthrough URL. Note this URL may not come through.
        let clickthroughURL: URL?
        
        /// Re-implement `init(from:)` to change desired functionality around decoding `clickthroughURL`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Try decoding image URL, but allow an exception to be thown if it fails to decode
            imageURL = try container.decode(URL.self, forKey: .imageURL)
            
            // Try decoding clickthrough URL if present, and set to `nil` rather than throw an exception
            // when the key is present, but fails to decode to a `URL`
            clickthroughURL = try? container.decodeIfPresent(URL.self, forKey: .clickthroughURL)
        }
        
        
        /// Server response keys
        private enum CodingKeys : String, CodingKey {
            case imageURL = "image"
            case clickthroughURL = "clk"
        }
    }
}
