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
    var messageId: String = ""
    var serverId: Int
    var message: String
    var messageType: IMMessageType
    var status: IMMessageStatus
    var createTime: Int
    var sendType: IMMessageSendType
    var chatterId: Int   //与你对话的人，如果是单聊那么是用户 id 如果是群组的话那么是群组 id
    var senderId: Int    //发送消息的人, 如果是单聊是用户 id， 如果是群聊，那么是发送消息的那个人的 id
    var metadataId: String?
    var chatType: IMChatType = IMChatType.IMChatSingleType
    var conversationId: String?
    
    override init() {
        localId = -1
        serverId = -1
        message = ""
        messageType = .TextMessageType
        status = .IMMessageSuccessful
        createTime = 0
        sendType = .MessageSendMine
        chatterId = -1
        senderId = -1
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
    初始化通过 contents 将具体消息的其他内容补充全,  子类重写
    :param: contents
    */
    func fillContentWithContent(contents: String) {
        
    }
    
    /**
    初始化通过 contents 将具体消息的其他内容补充全， 子类重写
    :param: contents
    */
    func fillContentWithContentDic(contentsDic: NSDictionary) {
        
    }

}
