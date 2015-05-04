//
//  ImageMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class ImageMessage: BaseMessage {
    var imageHeight: Int?
    var imageWidth: Int?
    var imageRatio: Float?
    var localPath: String?
    var originUrl: String?
    var thumbUrl: String?
    var fullUrl: String?
    
    override init() {
        super.init()
        messageType = .ImageMessageType
    }

    override func fillContentWithContent(contents: String) {
        var imageDic = super.jsonObjcWithString(message)
        imageHeight = imageDic.objectForKey("height") as? Int
        imageWidth = imageDic.objectForKey("width") as? Int
        originUrl = imageDic.objectForKey("origin") as? String
        thumbUrl = imageDic.objectForKey("thumb") as? String
        fullUrl = imageDic.objectForKey("full") as? String
    }

}
