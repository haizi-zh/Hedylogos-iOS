//
//  ChatConversation.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol ChatConversationDelegate {
    
    /**
    会话中的消息
    
    :param: messageChangedList
    */
    func receiverMessage(message: BaseMessage)
    
    /**
    消息发送完成
    :param: message   发送完成后的消息
    :param: errorCode 发送的错误代码
    */
    optional func didSendMessage(message: BaseMessage)
}

class ChatConversation: NSObject {
    var chatterId: Int
    var chatterName: String = ""
    var lastUpdateTime: Int = 0
    var unReadMsgCount: Int = 0
    var chatMessageList: NSMutableArray
    var chatType: IMChatType
    
    var delegate: ChatConversationDelegate?
    
    let chatManager: ChatManager
    
    init(chatterId: Int) {
        self.chatterId = chatterId
        chatMessageList = NSMutableArray()
        chatType = IMChatType.IMChatSingleType
        chatManager = ChatManager(chatterId: chatterId, chatType: chatType)
        super.init()
    }
    
//MARK: private function
    
    /**
    更新最新一条本地消息
    */
    var lastLocalMessage: BaseMessage? {
        get {
            var retMessage = chatMessageList.lastObject as? BaseMessage
            if retMessage != nil {
                return retMessage
                
            } else {
                var daoHelper = DaoHelper.shareInstance()
                var tableName = "chat_\(chatterId)"
                return daoHelper.selectLastLocalMessageInChatTable(tableName)
            }
        }
    }
    
    /**
    更新最后一条与服务器同步的 message, 默认的 serverid 为-1，如果大于0则为与服务器同步的 message
    */
    var lastServerMessage: BaseMessage? {
        get {
            for var i=chatMessageList.count-1; i>0; i-- {
                var message = chatMessageList.objectAtIndex(i) as! BaseMessage
                if message.serverId >= 0 {
                    return message
                }
            }
            
            var daoHelper = DaoHelper.shareInstance()
            var tableName = "chat_\(chatterId)"
            return daoHelper.selectLastServerMessage(tableName)
        
        }
    }
    
//MARK: public Internal function
    
    /**
    添加收到的消息到消息列表中
    :param: messageList
    */
    func addReceiveMessage(message: BaseMessage) {
        chatMessageList.addObject(message)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            delegate?.receiverMessage(message)
        })
    }
    
    /**
    初始化会话中的聊天记录
    */
    func initChatMessageInConversation(messageCount: Int) {
        chatMessageList = chatManager.selectChatMessageList(chatterId, untilLocalId: Int.max, messageCount: messageCount).mutableCopy() as! NSMutableArray
    }
    
    /**
    添加一条发送的消息的发送列表中
    :param: message
    */
    func addSendingMessage(message: BaseMessage) {
        chatMessageList.addObject(message)
    }
    
    /**
    消息发送完成，可能成功可能失败
    :param: message   发送完后的消息
    */
    func messageHaveSended(message: BaseMessage) {
        for var i=chatMessageList.count-1; i>0; i-- {
            var tempMessage = chatMessageList.objectAtIndex(i) as! BaseMessage
            if tempMessage.localId == message.localId {
                tempMessage.status = message.status
                tempMessage.serverId = message.serverId
            }
        }
        delegate?.didSendMessage?(message)
    }
}












