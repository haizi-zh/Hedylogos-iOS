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
    func someMessageAddedInConversation(messageChangedList: NSArray)
}

class ChatConversation: NSObject {
    var chatterId: Int
    var chatterName: String = ""
    var lastUpdateTime: Int = 0
    var lastLocalMessage: BaseMessage?
    var lastServerMessage: BaseMessage?
    var chatMessageList: NSMutableArray
    var chatType: IMChatType
    var delegate: ChatConversationDelegate?
    
    let chatManager: ChatManager
    
    init(chatterId: Int) {
        self.chatterId = chatterId
        chatMessageList = NSMutableArray()
        chatType = IMChatType.IMChatSingleType
        chatManager = ChatManager()
        chatMessageList = chatManager.selectChatMessageList(chatterId, untilLocalId: Int.max, messageCount: 20).mutableCopy() as! NSMutableArray
        super.init()
    }
    
    /**
    更新最新一条本地消息
    :param: message
    */
    func updateLastLocalMessage(message: BaseMessage) {
        lastLocalMessage = message
    }
    
    /**
    更新最后一条与服务器同步的 message
    :param: message
    */
    func updateLastServerMessage(message: BaseMessage) {
        lastServerMessage = message
    }
    
    func addMessageList(messageList: NSArray) {
        for message in messageList {
            chatMessageList .addObject(message)
        }
        delegate?.someMessageAddedInConversation(messageList)
    }
    
    func addMessage(message: BaseMessage) {
        chatMessageList.addObject(message)
        delegate?.someMessageAddedInConversation([message])
    }
    
}
