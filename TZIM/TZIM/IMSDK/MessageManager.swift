//
//  MessageManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/23/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

/// ACKArray 当超过多少是进行 ack
let MaxACKCount = 20
let ACKTime = 120.0


private let messageManger = MessageManager()

@objc protocol MessageManagerDelegate {
    func shouldACK(messageList: Array<String>)
    
}

class MessageManager: NSObject {
    
    let allLastMessageList: NSMutableDictionary
    weak var delegate: MessageManagerDelegate?
    
    private var timer: NSTimer!
    
    /// 储存将要 ACK 的消息
    var messagesShouldACK: Array<String> = Array()
    
    class func shareInsatance() -> MessageManager {
        return messageManger
    }
    
    override init() {
        var daoHelper = DaoHelper.shareInstance()
        allLastMessageList = daoHelper.selectAllLastServerChatMessageInDB().mutableCopy() as! NSMutableDictionary
        super.init()
        self.startTimer()
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
    
    func addChatMessage2ACK(message: BaseMessage) {
        messagesShouldACK.append(message.messageId)
        println("ACK消息队列里一共有\(messagesShouldACK.count)条数据")
        if messagesShouldACK.count > MaxACKCount {
            self.shouldACK()
        }
    }
    
    
    func ackMessageWhenTimeout() {
        self.shouldACK()
    }

    /**
    当 ack 成功后只清除ack 成功的数据
    
    :param: messageList 成功 ack 的消息
    */
    func clearMessageWhenACKSuccess(messageList: Array<BaseMessage>) {

    }
    
    /**
    当 ack 成功后清除说有的 ack 数据
    */
    func clearAllMessageWhenACKSuccess() {
        messagesShouldACK.removeAll(keepCapacity: false)
    }
    
    func shouldACK() {
        self.delegate?.shouldACK(messagesShouldACK)
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
        retDic.setValue(message.message, forKey: "contents")
        if let conversationId = message.conversationId {
            retDic.setValue(conversationId, forKey: "conversation")
        } else {
            retDic.setValue(receiverId, forKey: "receiver")
        }
        
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
    
    private func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(ACKTime, target: self, selector: Selector("ackMessageWhenTimeout"), userInfo: nil, repeats: true)
        println("********ACK 的定时器开始启动了*******")
    }
    
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
                messageModel!.conversationId = messageDic.objectForKey("conversation") as? String
                messageModel!.createTime = messageDic.objectForKey("timestamp") as! Int
                
                if let senderId = messageDic.objectForKey("senderId") as? Int {
                    messageModel!.chatterId = senderId
                }
                if let senderId = messageDic.objectForKey("msgId") as? Int {
                    messageModel!.serverId = senderId
                }
                
                if let messageId = messageDic.objectForKey("id") as? String {
                    messageModel?.messageId = messageId
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
