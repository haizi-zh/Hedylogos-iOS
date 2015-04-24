//
//  MessageManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/23/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class MessageManager: NSObject {
   
    /**
    将 MessageModel转化成发送的消息格式
    :param: receiverId
    :param: senderId
    :param: message
    :returns:
    */
    class func prepareMessage2Send(#receiverId: Int, senderId: Int, message:BaseMessage) ->  NSDictionary {
        var retDic = NSMutableDictionary()
        retDic.setValue(message.type, forKey: "msgType")
        retDic.setValue(100, forKey: "sender")
        retDic.setValue(1, forKey: "receiver")
        retDic.setValue(message.message, forKey: "contents")
        
        switch message {
        case message as LocationMessage :
            retDic .setValue("locationMessage", forKey: "contents")
        case message as TextMessage:
            retDic.setValue(message.message, forKey: "contents")
            
        default:
            break
        }
        return retDic
    }
    
    /**
    将 其他类型的 message 转为 MessageModel 类型
    :param: messageObjc
    :returns:
    */
    class func messageModelWithMessage(messageObjc: AnyObject) -> BaseMessage {
        if let messageDic = messageObjc as? NSDictionary {
            return MessageManager.messageModelWithMessageDic(messageDic)
        } else {
            var messageModel = BaseMessage()
            messageModel.message = messageObjc as! String
            return messageModel
        }
    }
        
    private class func messageModelWithMessageDic(messageDic: NSDictionary) -> BaseMessage {
        var messageModel: BaseMessage
        let messageType = messageDic.objectForKey("msgType")?.integerValue
        switch messageType! {
        case 0 :
            messageModel = TextMessage()
        case 1 :
            messageModel = ImageMessage()
        default :
            messageModel = BaseMessage()
        }
        messageModel.message = messageDic.objectForKey("contents") as! String
        messageModel.createTime = Int(NSDate().timeIntervalSince1970)
        messageModel.sendType = 1
        return messageModel
    }
}
