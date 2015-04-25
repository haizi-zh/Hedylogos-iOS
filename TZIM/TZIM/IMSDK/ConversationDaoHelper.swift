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
        if !super.tableIsExit(conversationTableName) {
            createConversationsTable()
        }
        if !super.tableIsExit(frendTableName) {
            UserDaoHelper.createFrendTable(dataBase)
        }
        var retArray = NSMutableArray()
        var sql = "select * from \(conversationTableName) left join \(frendTableName) on \(conversationTableName).UserId = \(frendTableName).UserId order by LastUpdateTime DESC"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
        if rs != nil {
            while rs.next() {
                var conversation = ChatConversation()
                conversation.chatterId =  Int(rs.intForColumn("UserId"))
                conversation.lastUpdateTime = Int(rs.intForColumn("LastUpdateTime"))
                conversation.chatterName =  rs.stringForColumn("NickName")
                conversation.chatType = IMChatType(rawValue: Int(rs.intForColumn("Type")))!
                self.fillConversationWithMessage(conversation)
                retArray .addObject(conversation)
            }
        }
        return retArray
    }
    
    /**
    补全 conversation 的具体内容
    :param: conversation 需要补全的 conversation,具体是补全 conversation 的最后一条本地消息，和最后一条和服务器同步的消息
    */
    private func fillConversationWithMessage(conversation: ChatConversation) {
        var localSql = "select * from chat_\(conversation.chatterId) order by LocalId DESC LIMIT 1"
        var localRS = dataBase.executeQuery(localSql, withArgumentsInArray: nil)
        if localRS != nil {
            while localRS.next() {
                conversation.lastLocalMessage = ChatMessageDaoHelper.messageModelWithFMResultSet(localRS)
            }
        }

        var serverSql = "select * from chat_\(conversation.chatterId) where status = ? order by LocalId DESC LIMIT 1"
        var serverRS = dataBase.executeQuery(serverSql, withArgumentsInArray: [IMMessageStatus.IMMessageReaded.rawValue])
        
        if serverRS != nil {
            while serverRS.next() {
                conversation.lastServerMessage = ChatMessageDaoHelper.messageModelWithFMResultSet(serverRS)
            }
        }
    }
    
//MARK: *******  ConversationDaoProtocol  ******
    /**
    创建一个会话表
    :returns:
    */
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
    
    /**
    添加一个会话
    :param: userId         会话的 chatter ID
    :param: lastUpdateTime 最后一次更新的时间
    */
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
    
    /**
    获取所有的会话列表
    :returns:
    */
    func getAllConversationList() -> NSArray {
        var retArray = self.getAllCoversation()
        return retArray
    }
   
    
    
    
    
    
    
    
    
}
