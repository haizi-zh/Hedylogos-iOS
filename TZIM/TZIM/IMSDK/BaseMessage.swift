//
//  BaseMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class BaseMessage: NSObject {
    var localId: Int
    var serverId: Int
    var message: String
    var messageType: IMMessageType
    var status: IMMessageStatus
    var createTime: Int
    var sendType: IMMessageSendType
    var chatterId: Int
    var metaDataId: String?
    
    override init() {
        localId = -1
        serverId = -1
        message = ""
        messageType = .TextMessageType
        status = .IMMessageSuccessful
        createTime = 0
        sendType = .MessageSendMine
        chatterId = -1
        super.init()
    }
    
    func jsonObjcWithString(messageStr: String) -> NSDictionary {
        var mseesageData = messageStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var messageJson: AnyObject? = NSJSONSerialization.JSONObjectWithData(mseesageData!, options:.AllowFragments, error: nil)
        if messageJson is NSDictionary {
            return messageJson as! NSDictionary
        } else {
            return NSDictionary()
       }
    }
    
    func contentsStrWithJsonObjc(messageDic: NSDictionary) -> NSString? {
        var jsonData = NSJSONSerialization.dataWithJSONObject(messageDic, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var retStr = NSString(data:jsonData!, encoding: NSUTF8StringEncoding)
        return retStr
    }
    
    /**
    初始化通过 contents 将具体消息的其他内容补充全
    :param: contents
    */
    func fillContentWithContent(contents: String) {
        
    }
    
    /**
    初始化通过 contents 将具体消息的其他内容补充全
    :param: contents
    */
    func fillContentWithContentDic(contentsDic: NSDictionary) {
        
    }

}
