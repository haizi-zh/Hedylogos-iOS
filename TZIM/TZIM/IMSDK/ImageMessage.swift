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
        var imageDic = super.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        imageHeight = contentsDic.objectForKey("height") as? Int
        imageWidth = contentsDic.objectForKey("width") as? Int
        originUrl = contentsDic.objectForKey("origin") as? String
        thumbUrl = contentsDic.objectForKey("thumb") as? String
        fullUrl = contentsDic.objectForKey("full") as? String
        if let imageId = contentsDic.objectForKey("metadataId") as? String {
            localPath = IMAccountManager.shareInstance().userChatImagePath.stringByAppendingPathComponent("\(imageId).jpeg")
        }
    }
    
    /**
    更新消息的主体内容，一般是下载附件完成后填入新的 metadataId
    */
    func updateMessageContent() {
        var imageDic: NSMutableDictionary = super.jsonObjcWithString(message).mutableCopy() as! NSMutableDictionary
        if let metadataId = metadataId {
            imageDic.setObject(metadataId, forKey: "metadataId")
            if let content = super.contentsStrWithJsonObjc(imageDic) {
                message = content as String
            }
        }
    }
    

}
