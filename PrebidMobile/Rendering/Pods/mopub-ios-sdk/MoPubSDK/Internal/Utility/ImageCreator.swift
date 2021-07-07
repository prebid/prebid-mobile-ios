//
//  ImageCreator.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import UIKit


@objc(MPImageCreator)
public final class ImageCreator: NSObject {
    /// Creates either an animated `UIImage` from a GIF, or a static `UIImage` from any other format.
    /// - Parameters:
    ///     - data: The data to create the image from.
    /// - Returns: A `UIImage` if one could be created, or nil if not.
    @objc public static func image(with data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        return createAnimatedImage(from: source) ?? UIImage(data: data)
    }
}

// MARK: - Helpers
private extension ImageCreator {
    struct Constants {
        // Specify the 0.1 as the default GIF delay time, which is the same
        // as the clamped delay time.
        static let defaultGIFDelay: TimeInterval = 0.1
    }
    
    static func canCreateAnimatedImage(from source: CGImageSource) -> Bool {
        let frameCount = CGImageSourceGetCount(source)
        
        // CFDictionary is toll-free bridged with NSDictionary, but it's much
        // more expensive to cast to a native Swift dictionary.
        let properties: NSDictionary? = CGImageSourceCopyProperties(source, nil)
        
        // Only support GIFs for now.
        return properties?[kCGImagePropertyGIFDictionary] != nil && frameCount > 1
    }
    
    static func createAnimatedImage(from source: CGImageSource) -> UIImage? {
        guard canCreateAnimatedImage(from: source) else {
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(source)
        
        // Get the duration from the first frame.
        let frameProperties: NSDictionary? = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
        let gifProperties = frameProperties?[kCGImagePropertyGIFDictionary] as? NSDictionary
        let delay: TimeInterval = gifProperties?[kCGImagePropertyGIFDelayTime] as? TimeInterval ?? Constants.defaultGIFDelay
        let duration: TimeInterval = TimeInterval(frameCount) * delay
        
        var frames: [UIImage] = []
        
        for i in 0..<frameCount {
            guard let frame = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }
            
            let uiImage = UIImage(cgImage: frame)
            frames.append(uiImage)
        }
        
        return UIImage.animatedImage(with: frames, duration: duration)
    }
}
