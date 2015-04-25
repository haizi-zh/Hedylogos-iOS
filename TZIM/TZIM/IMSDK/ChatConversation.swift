//
//  ChatConversation.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol ChatConversationDelegate {
    
    /**
    会话中的消息
    
    :param: messageChangedList
    */
    func someMessageAddedInConversation(messageChangedList: NSArray)
}

class ChatConversation: NSObject {
    var chatterId: Int = -1
    var chatterName: String = ""
    var lastUpdateTime: Int = 0
    var lastLocalMessage: BaseMessage?
    var lastServerMessage: BaseMessage?
    var chatMessageList: NSMutableArray
    var chatType: IMChatType
    var delegate: ChatConversationDelegate?
    
    override init() {
        chatMessageList = NSMutableArray()
        chatType = IMChatType.IMChatSingleType
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
    
    func addMessage(messageList: NSArray) {
        
        delegate?.someMessageAddedInConversation(messageList)
    }
    
}
