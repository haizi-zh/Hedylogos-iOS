//
//  ConversationDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.

import UIKit

private let conversationTableName = "ConversationList"

protocol ConversationDaoProtocol {
    /**
    创建FrendMeta表，用于存放聊天列表信息
    :returns:
    */
    func createConversationsTable() -> Bool;
    
    /**
    添加一条记录会话列表记录
    :param: userId 会话列表 id
    :param: lastUpdateTime 会话列表最后一次更新的时间
    */
    func addConversation(userId: Int, lastUpdateTime: Int)
    
    /**
    获取所有的聊天会话列表
    :returns:
    */
    func getAllConversationList() -> NSArray
}

class ConversationDaoHelper: BaseDaoHelper, ConversationDaoProtocol {
    
    // MARK: private method
    /**
    从会话列表数据库里获取所有的会话列表,按照时间逆序排列
    :returns: 包含所有会话列表
    */
    private func getAllCoversation() -> NSArray {
        var retArray = NSMutableArray()
        var sql = "select * from \(conversationTableName) left join \(frendTableName) on \(conversationTableName).UserId = \(frendTableName).UserId order by LastUpdateTime DESC"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
        if rs != nil {
            while rs.next() {
                var conversation = ChatConversation()
                conversation.chatterId =  Int(rs.intForColumn("UserId"))
                conversation.lastUpdateTime = Int(rs.intForColumn("LastUpdateTime"))
                conversation.chatterName =  rs.stringForColumn("NickName")
                conversation.chatType = Int(rs.intForColumn("Type"))
                self.fillConversationWithMessage(conversation)
                retArray .addObject(conversation)
            }
        }
        return retArray
    }
    
    /**
    补全 conversation 的具体内容
    :param: conversation 需要补全的 conversation
    */
    private func fillConversationWithMessage(conversation: ChatConversation) {
        var sql = "select * from chat_\(conversation.chatterId) order by LocalId DESC LIMIT 1"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
        if (rs != nil) {
            while rs.next() {
                var message = BaseMessage()
                message.message = rs.stringForColumn("message")
                conversation.lastMessage = message
            }
        }
    }
    
    //MARK: ConversationDaoProtocol
    func createConversationsTable() -> Bool {
        var sql = "create table '\(conversationTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, LastUpdateTime INTEGER)"
        if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
            println("执行 sql 语句：\(sql)")
            dataBase.close()
            return true
        } else {
            dataBase.close()
            return false
        }
    }
    
    func addConversation(userId: Int, lastUpdateTime: Int) {
        if !tableIsExit(conversationTableName) {
            self.createConversationsTable()
        }
        var sql = "insert into \(conversationTableName) (UserId, LastUpdateTime) values (?,?)"
        var array = [userId, lastUpdateTime]
        if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
            println("执行 sql 语句：\(sql)")
        }
    }
    
    func getAllConversationList() -> NSArray {
        var retArray = self.getAllCoversation()
        return retArray
    }
   
    
    
    
    
    
    
    
    
}
