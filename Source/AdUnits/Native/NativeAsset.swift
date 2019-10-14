//
//  AssetTitle.swift
//  PrebidMobile
//
//  Created by Punnaghai Puviarasu on 10/8/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

import UIKit
public class NativeAsset:NSObject {
    var id:NSInteger!
    public var required:Bool = false
    public var title:NativeAssetTitle?
    public var image:NativeAssetImage?
    public var video:NativeAssetVideo?
    public var data:NativeAssetData?
    public var ext:AnyObject?
    
    func getAssetObject() -> [AnyHashable: Any] {
        var asset: [AnyHashable: Any] = [:]
        
        asset["id"] = Int.random(in: 0...1000)
        asset["required"] = Int(truncating: NSNumber(value:required))
        if (title != nil) {
            asset["title"] = title!.getTitleObject()
        }
        if(image != nil){
            asset[image] = image!.getImageObject()
        }
        if(video != nil){
            asset["video"] = video!.getVideoObject()
        }
        if(data != nil){
           asset["data"] = data!.getDataObject()
        }
        if(ext != nil){
            asset["ext"] = ext!
        }
        
        return asset
    }
    
}
@objcMembers public class NativeAssetTitle: NSObject {
    
    var length:NSInteger! = 25
    
    public var ext:AnyObject?
    
    public required init(length:NSInteger) {
        super.init()
        self.length = length
    }
    
    func getTitleObject() -> [AnyHashable:Any] {
        var title: [AnyHashable: Any] = [:]
        
        title["len"] = length
        if(ext != nil){
            title["ext"] = ext
        }
        return title
    }
    
}



public class NativeAssetImage:NSObject {
    
    public var type:ImageAsset?
    public var width:Int?
    public var widthMin:Int?
    public var height:Int?
    public var heightMin:Int?
    public var mimes:Array<String>?
    public var ext:AnyObject?
    
    public convenience init(minimumWidth:Int,minimumHeight:Int){
        self.init()
        self.widthMin = minimumWidth
        self.heightMin = minimumHeight
    }
    
    func getImageObject() -> [AnyHashable:Any] {
        
        var image: [AnyHashable: Any] = [:]
        if(type != nil){
            image["type"] = type
        }
        if(width != nil){
            image["w"] = width!
        }
        if(widthMin != nil){
            image["wmin"] = widthMin!
        }
        if(height != nil){
            image["h"] = height!
        }
        if(heightMin != nil){
            image["hmin"] = heightMin!
        }
        if(mimes != nil){
            image["mimes"] = mimes!
        }
        if(ext != nil){
            image["ext"] = ext
        }
        return image
    }
    
}

public class NativeAssetVideo:NSObject {
    
    public var mimes:Array<String>!
    public var protocols:Array<Int>!
    public var minDuration:Int!
    public var maxDuration:Int!
    public var ext:AnyObject?
    
    required public init(mimes:Array<String>, protocols:Array<Int>,minduration:Int,maxduration:Int){
        super.init()
        self.mimes = mimes
        self.protocols = protocols
        self.minDuration = minduration
        self.maxDuration = maxduration
    }
    
    func getVideoObject() -> [AnyHashable:Any] {
        
        var video: [AnyHashable: Any] = [:]
        if(protocols != nil){
            video["protocols"] = protocols
        }
        if(minDuration != nil){
            video["minDuration"] = minDuration!
        }
        if(maxDuration != nil){
            video["maxDuration"] = maxDuration!
        }
        if(mimes != nil){
            video["mimes"] = mimes!
        }
        if(ext != nil){
            video["ext"] = ext
        }
        return video
    }
    
    
}

public class NativeAssetData:NSObject {
    var type:Int!
    public var length:Int?
    public var ext:AnyObject?
    
    required public init(type:Int) {
        super.init()
        self.type = type
    }
    
    func getDataObject() -> [AnyHashable:Any]{
        var data: [AnyHashable: Any] = [:]
        data["type"] = type
        
        if(length != nil){
            data["len"] = length!
        }
        if(ext != nil){
            data["ext"] = ext
        }
        return data
    }
}


@objc public enum ImageAsset: Int {
    case Icon = 1
    case Main = 3
    case XXX = 500
}
