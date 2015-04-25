//
//  ChatConversationManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol ChatConversationManagerDelegate {
    
    /**
    会话列表状态需要更新
    :param: 需要更新的会话
    */
    func conversationStatusHasChanged(conversation: ChatConversation)
    
    /**
    有些会话已经移除
    :param: conversationList
    */
    func conversationsHaveRemoved(conversationList: NSArray)
    
    /**
    有些会话已经添加
    :param: conversationList
    */
    func conversationsHaveAdded(conversationList: NSArray)
    
}

class ChatConversationManager: NSObject, MessageTransferManagerDelegate {
    
    private var conversationList: NSMutableArray
    
    var delegate: ChatConversationManagerDelegate?
        
    override init() {
        conversationList = NSMutableArray()
        super.init()
    }
    
    func getConversationList() -> NSArray {
        self.updateConversationList()
        return conversationList
    }
    
    private func updateConversationList() {
        var daoHelper = DaoHelper()
        NSLog("****开始获取会话列表*****")
        if daoHelper.openDB() {
            conversationList = daoHelper.getAllConversationList() as! NSMutableArray
            daoHelper.closeDB()
        }
        NSLog("****结束获取会话列表*****")
    }

    /**
    新建会话列表, 会话的 用户 id
    */
    func createNewConversation(chatterId: Int) {
        self.addConversation(chatterId)
    }
    
    /**
     添加一个会话到会话列表里
    :param: chatterId
    */
    func addConversation(chatterId: Int) {
        for conversation in conversationList {
            if (conversation as! ChatConversation).chatterId == chatterId {
                return
            }
        }
        var daoHelper = DaoHelper()
        var time = NSDate().timeIntervalSince1970
        var timeInt: Int = Int(round(time))
        if daoHelper.openDB() {
            daoHelper.addConversation(chatterId, lastUpdateTime: timeInt)
            daoHelper.closeDB()
            self.addConversation2ConversationList(chatterId, lastUpdateTime: timeInt)
        }
        delegate?.conversationsHaveAdded(conversationList)
    }
    
    /**
    移除一个 conversation
    :param: chatterId
    :Bool: 是否成功
    */
    func removeConversation(chatterId: Int) -> Bool {
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            if daoHelper.removeConversationfromDB(chatterId) {
                daoHelper.closeDB()
                for conversation in conversationList {
                    if let conversation = conversation as? ChatConversation {
                        if conversation.chatterId == chatterId {
                            conversationList.removeObject(conversation)
                            delegate?.conversationsHaveRemoved([conversation])
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    
//MARK: private methods
    /**
    添加一个会话到会话列表里
    :param: userId         会话列表 id
    :param: lastUpdateTime 最后更新的时间
    */
    private func addConversation2ConversationList(userId: Int, lastUpdateTime: Int) {
        var conversation = ChatConversation(chatterId: userId)
        conversation.lastUpdateTime = lastUpdateTime
        conversationList.addObject(conversation)
    }
    
    /**
    处理收到的消息，将收到的消息对应的插入 conversation 里，更新最后一条本地消息，和最后一条服务器消息
    :param: message 待处理的消息
    */
    private func handleReceiveMessage(message: BaseMessage) {
        for conversation in conversationList {
            if let conversation = conversation as? ChatConversation {
                if conversation.chatterId == message.chatterId {
                    conversation.addMessage(message)
                    conversation.updateLastLocalMessage(message)
                    conversation.updateLastServerMessage(message)
                    delegate?.conversationStatusHasChanged(conversation)
                    return
                }
            }
        }
        createNewConversation(message.chatterId)
    }
    
    /**
    处理刚开始发送的消息。只更新最后一条本地消息，等发送成功后更新最后一条本地消息
    :param: message
    */
    private func handleSendingMessage(message: BaseMessage) {
        for conversation in conversationList {
            if let conversation = conversation as? ChatConversation {
                if conversation.chatterId == message.chatterId {
                    conversation.addMessage(message)
                    conversation.updateLastLocalMessage(message)
                    delegate?.conversationStatusHasChanged(conversation)
                    return
                }
            }
        }
    }
    
    /**
    处理已经发送成功的消息，更新指定 conversation 里的最后一条服务器消息
    :param: message
    */
    private func handleSendedMessage(message: BaseMessage) {
        for conversation in conversationList {
            if let conversation = conversation as? ChatConversation {
                if conversation.chatterId == message.chatterId {
                    conversation.updateLastServerMessage(message)
                    delegate?.conversationStatusHasChanged(conversation)
                    return
                }
            }
        }
    }
    
    
//MARK: MessageTransferManagerDelegate
    
    /**
    会话中增加了一条新消息
    :param: message
    */
    func receiveNewMessage(message: BaseMessage) {
        self.handleReceiveMessage(message)
    }
    
    func messageHasSended(message: BaseMessage) {
        self.handleSendedMessage(message)
    }
    
    func sendNewMessage(message: BaseMessage) {
        self.handleSendingMessage(message)
    }
    
}










