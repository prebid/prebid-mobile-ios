//
//  ImageCreativeView.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit


/// `ImageCreativeView` is a `UIImageView` subclass with a `UIClickGestureRecognizer`
/// attached to detect clicks, and with some sensible default settings for ad creatives.
/// Clicks are not enabled by default, but can be enabled when desired by calling
/// `enableClick()`. Click events can be captured by setting the `delegate` object
/// and implementing `imageCreativeViewWasClicked(_:)`.
@objc(MPImageCreativeView)
public class ImageCreativeView: UIImageView {
    /// Required `init?(coder:)` had to be overridden.
    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        sharedInitializationSteps()
    }
    
    /// Override so `init(frame:)` works too.
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        
        sharedInitializationSteps()
    }
    
    /// Convenience `init` for ease-of-use programatically.
    @objc public convenience init() {
        self.init(frame: .zero)
    }
    
    /// Flag indicating if clicks are presently enabled.
    @objc public var isClickable: Bool {
        get {
            return clickGestureRecognizer.isEnabled
        }
    }
    
    /// Latch to enable clicks (they cannot be disabled once enabled).
    @objc public func enableClick() {
        clickGestureRecognizer.isEnabled = true
    }
    
    /// Delegate to receive click events
    @objc public weak var delegate: ImageCreativeViewDelegate? = nil
    
    /// Shared initialization steps since `init(frame:)` won't call `init?(coder:)`
    private func sharedInitializationSteps() {
        // Configure view for ad rendering
        isUserInteractionEnabled = true // Enable user interaction so clicks pipe through
    }
    
    /// Gesture recognizer to track clickthroughs
    private lazy var clickGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wasTapped(sender:)))
        addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.isEnabled = false // Disable clicks by default
        return gestureRecognizer
    }()
    
    /// Receiving method when the gesture recognizer is tapped
    @objc private func wasTapped(sender: UITapGestureRecognizer) {
        delegate?.imageCreativeViewWasClicked?(self)
    }
    
    /// Override `layoutSubviews()` to alter the `contentMode` to either center or aspect fit the image
    /// The image should be centered without scaling if it is smaller than the view dimensions.
    /// The image should be scaled down via aspect-fit if it is larger than the view dimensions.
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Default to the assumption that the image is larger than the container
        var imageIsSmallerThanContainer = false
        
        // Flip the boolean if the image is smaller than the container
        if let imageSize = image?.size,
           imageSize.width < bounds.width
            && imageSize.height < bounds.height {
            imageIsSmallerThanContainer = true
        }
        
        // If the image is smaller than the container, center it. Otherwise, aspect fit it.
        contentMode = imageIsSmallerThanContainer ? .center : .scaleAspectFit
    }
}


@objc(MPImageCreativeViewDelegate)
public protocol ImageCreativeViewDelegate {
    
    /// This method is notified when the image view was tapped
    @objc optional func imageCreativeViewWasClicked(_ imageCreativeView: ImageCreativeView)
}
