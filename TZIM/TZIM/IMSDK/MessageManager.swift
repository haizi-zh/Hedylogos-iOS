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
        retDic.setValue(message.messageType.rawValue, forKey: "msgType")
        retDic.setValue(senderId, forKey: "sender")
        retDic.setValue(receiverId, forKey: "receiver")
        retDic.setValue(message.message, forKey: "contents")
        
        switch message.messageType {
        case .LocationMessageType :
            retDic .setValue("locationMessage", forKey: "contents")
        case .TextMessageType :
            retDic.setValue(message.message, forKey: "contents")
            
        case .ImageMessageType :
            retDic.setValue("image: \(message.localId)", forKey: "contents")
            
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
    class func messageModelWithMessage(messageObjc: AnyObject) -> BaseMessage? {
        if let messageDic = messageObjc as? NSDictionary {
            return MessageManager.messageModelWithMessageDic(messageDic)
        } else if let messageStr = messageObjc as? String {
            return MessageManager.messageModelWithMessageDic(MessageManager.jsonObjcWithString(messageStr))
        }
        return nil
    }
       
//MARK: private methods
    private class func messageModelWithMessageDic(messageDic: NSDictionary) -> BaseMessage? {
        var messageModel: BaseMessage?
        let messageTypeInteger = messageDic.objectForKey("msgType")?.integerValue
        if let messageType = IMMessageType(rawValue: messageTypeInteger!) {
            switch messageType {
            case .TextMessageType :
                messageModel = TextMessage()
            case .ImageMessageType :
                messageModel = ImageMessage()
            case .AudioMessageType:
                messageModel = AudioMessage()
            default :
                messageModel = BaseMessage()
            }
            if let message = messageDic.objectForKey("contents") as? String {
                messageModel!.message = message
            }
            messageModel!.createTime = Int(NSDate().timeIntervalSince1970)
            if let senderId = messageDic.objectForKey("senderId") as? Int {
                messageModel!.chatterId = senderId
            }
        }
        return messageModel
    }
    
    private class func jsonObjcWithString(messageStr: String) -> NSDictionary {
        var mseesageData = messageStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        var messageJson: AnyObject? = NSJSONSerialization.JSONObjectWithData(mseesageData!, options:.AllowFragments, error: nil)
        if messageJson is NSDictionary {
            return messageJson as! NSDictionary
        } else {
            return NSDictionary()
        }
    }
    
    

    
    
    
    
}
