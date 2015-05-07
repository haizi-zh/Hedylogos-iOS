//
//  MessageManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/23/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let messageManger = MessageManager()

class MessageManager: NSObject {
    
    let allLastMessageList: NSMutableDictionary
    
    class func shareInsatance() -> MessageManager {
        return messageManger
    }
    
    override init() {
        var daoHelper = DaoHelper.shareInstance()
        allLastMessageList = daoHelper.selectAllLastServerChatMessageInDB().mutableCopy() as! NSMutableDictionary
      
        super.init()
    }
    
    func updateLastServerMessage(message: BaseMessage) {
        if let lastMessage: AnyObject = allLastMessageList.objectForKey(message.chatterId) {
            if (lastMessage as! Int) < message.serverId {
                allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
            }
        } else {
            allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
        }
    }
   
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
        if let messageTypeInteger = messageDic.objectForKey("msgType")?.integerValue {
        
            if let messageType = IMMessageType(rawValue: messageTypeInteger) {
                switch messageType {
                case .TextMessageType :
                    messageModel = TextMessage()
                case .ImageMessageType :
                    messageModel = ImageMessage()
                    messageModel?.metadataId = NSUUID().UUIDString
                case .AudioMessageType:
                    messageModel = AudioMessage()
                    messageModel?.metadataId = NSUUID().UUIDString

                default :
                    break
                }
                
                if messageModel == nil {
                    return nil
                }
                
                if let contents = messageDic.objectForKey("contents") as? String {
                    messageModel!.message = contents
                    messageModel?.fillContentWithContent(contents)
                }
                
                messageModel!.createTime = messageDic.objectForKey("timestamp") as! Int
                
                if let senderId = messageDic.objectForKey("senderId") as? Int {
                    messageModel!.chatterId = senderId
                }
                if let senderId = messageDic.objectForKey("msgId") as? Int {
                    messageModel!.serverId = senderId
                }
            }
        } else {
            println(" ****解析消息出错******")
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
