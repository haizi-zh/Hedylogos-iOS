//
//  AudioMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class AudioMessage: BaseMessage {
    var audioLength: Float = 0.0
    var audioStatus: Int = 0
    var localPath: String?
    var remoteUrl: String?
    
    override init() {
        super.init()
        messageType = .AudioMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var audioDic = super.jsonObjcWithString(contents)
        self.fillContentWithContentDic(audioDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let length = contentsDic.objectForKey("duration") as? Float {
            audioLength = length
        }
        
        if let audioId = contentsDic.objectForKey("metadataId") as? String {
            localPath = AccountManager.shareInstance().userChatAudioPath.stringByAppendingPathComponent("\(audioId).wav")
        }

        remoteUrl = contentsDic.objectForKey("url") as? String
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
