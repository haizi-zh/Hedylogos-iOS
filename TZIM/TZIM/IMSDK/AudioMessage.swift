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
    
    override init() {
        super.init()
        messageType = .AudioMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var audioDic = super.jsonObjcWithString(contents)
        self.fillContentWithContentDic(audioDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let length = contentsDic.objectForKey("length") as? Float {
            audioLength = length
        }
        
        var audioId = contentsDic.objectForKey("metadataId") as? String
        localPath = AccountManager.shareInstance().userChatImagePath.stringByAppendingPathComponent("\(audioId).amr")

    }

   
}
