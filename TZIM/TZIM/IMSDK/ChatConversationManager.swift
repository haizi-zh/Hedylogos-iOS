//
//  ChatConversationManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol ChatConversationDelegate {
    
    /**
    会话列表需要更新
    
    :param: conversationList 更新后的会话列表
    */
    func conversationsNeedUpdate(conversationList: NSArray)
}

class ChatConversationManager: NSObject {
    
    var conversationList: NSMutableArray
    
    var chatConversationDelegate: ChatConversationDelegate?
    
    override init() {
        conversationList = NSMutableArray()
    }
    
    func updateConversationList() {
        var daoHelper = DaoHelper()
        NSLog("****开始获取会话列表*****")
        if daoHelper.openDB() {
            conversationList = daoHelper.getAllConversationList() as! NSMutableArray
            daoHelper.closeDB()
        }
        fillConversationWithUserInfo()
        NSLog("****结束获取会话列表*****")
    }
    
    /**
    将会话填充上用户属性
    */
    func fillConversationWithUserInfo() {
        
    }
    
    /**
    新建会话列表, 会话的 用户 id
    */
    func createNewConversation(chatterId: Int) {
        
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
        daoHelper.addConversation(chatterId, lastUpdateTime: timeInt)
        self.addConversation2ConversationList(chatterId, lastUpdateTime: timeInt)
    }
    
    /**
    添加一个会话到会话列表里
    :param: userId         会话列表 id
    :param: lastUpdateTime 最后更新的时间
    */
    private func addConversation2ConversationList(userId: Int, lastUpdateTime: Int) {
        var conversation = ChatConversation()
        conversation.chatterId = userId
        conversation.lastUpdateTime = lastUpdateTime
        conversationList.addObject(conversation)
    }
    
    
    
   
}
