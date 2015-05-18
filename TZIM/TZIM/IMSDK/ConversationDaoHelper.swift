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
    func createConversationsTable();
    
    /**
    添加一条记录会话列表记录
    :param: userId 会话列表 id
    :param: lastUpdateTime 会话列表最后一次更新的时间
    */
    func addConversation(conversation :ChatConversation)
    
    /**
    获取所有的聊天会话列表
    :returns:
    */
    func getAllCoversation() -> Array<ChatConversation>
    
    /**
    移除一个 conversation
    :param: chatterId 需要移除的 ID
    :returns: 移除是否成功
    */
    func removeConversationfromDB(chatterId: Int)
    
    /**
    更新某个会话的未读消息的数量
    
    :param: conversation
    */
    func updateUnreadMessageCountInConversation(unReadMessageCount: Int, userId: Int)
    
    /**
    更新会话的时间戳
    
    :param: timeStamp
    :param: userId    
    */
    func updateTimestampInConversation(timeStamp: Int, userId: Int)
    
    /**
    更新会话的会话 id
    
    :param: conversationId
    :param: userId         
    */
    func updateConversationIdInConversation(conversationId: String, userId: Int)

}

class ConversationDaoHelper: BaseDaoHelper, ConversationDaoProtocol {
    
    //MARK: *******  ConversationDaoProtocol  ******

    /**
    从会话列表数据库里获取所有的会话列表,按照时间逆序排列
    :returns: 包含所有会话列表
    */
    func getAllCoversation() -> Array<ChatConversation> {
        var retArray = Array<ChatConversation>()
        
        if !super.tableIsExit(conversationTableName) {
            self.createConversationsTable()
        }
        if !super.tableIsExit(frendTableName) {
            FrendDaoHelper.createFrendTable(dataBase)
        }
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
          
            var sql = "select * from \(conversationTableName) left join \(frendTableName) on \(conversationTableName).UserId = \(frendTableName).UserId order by LastUpdateTime DESC"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
            if rs != nil {
                while rs.next() {
                    var conversation = ChatConversation()
                    conversation.chatterId = Int(rs.intForColumn("UserId"))
                    conversation.lastUpdateTime = Int(rs.intForColumn("LastUpdateTime"))
                    if let chatterName = rs.stringForColumn("NickName") {
                        conversation.chatterName = chatterName
                    }
                    var typeValue  = rs.intForColumn("Type")
                    conversation.fillConversationType(frendType: IMFrendType(rawValue: Int(typeValue))!)
                    conversation.unReadMessageCount = Int(rs.intForColumn("UnreadMessageCount"))
                    if let conversationId = rs.stringForColumn("ConversationId") {
                        conversation.conversationId = String(conversationId)
                    }

                    retArray.append(conversation)
                }
            }
        }
        return retArray
    }
    
    /**
    创建一个会话表
    :returns:
    */
    func createConversationsTable() {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in

            var sql = "create table '\(conversationTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, LastUpdateTime INTEGER, ConversationId String, UnreadMessageCount INTEGER)"
            
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                println("success 执行 sql 语句：\(sql)")
            } else {
                println("error 执行 sql 语句：\(sql)")

            }
        }
    }
    
    /**
    添加一个会话
    :param: userId         会话的 chatter ID
    :param: lastUpdateTime 最后一次更新的时间
    */
    func addConversation(conversation :ChatConversation) {
        if !self.tableIsExit(conversationTableName) {
            self.createConversationsTable()
        }
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in

            if let conversationId = conversation.conversationId {
                var sql = "insert or replace into \(conversationTableName) (UserId, LastUpdateTime, ConversationId) values (?,?,?)"
                println("执行 addConversation userId: \(conversation.chatterId)")
                var array = [conversation.chatterId, conversation.lastUpdateTime, conversationId]
                if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                    println("success 执行 sql 语句：\(sql)")
                    
                } else {
                    println("error 执行 sql 语句：\(sql)")
                }
                
            } else {
                var sql = "insert or replace into \(conversationTableName) (UserId, LastUpdateTime) values (?,?)"
                println("执行 addConversation userId: \(conversation.chatterId)")
                var array = [conversation.chatterId, conversation.lastUpdateTime]
                if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                    println("success 执行 sql 语句：\(sql)")
                    
                } else {
                    println("error 执行 sql 语句：\(sql)")
                    
                }
            }
        }
    }
    
    
    func updateUnreadMessageCountInConversation(unReadMessageCount: Int, userId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "update \(conversationTableName) set UnreadMessageCount = ? where UserId = ?"
            println("执行 updateUnreadMessageCountInConversation userId: \(userId)")
            var array = [unReadMessageCount, userId]
            if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                println("success 执行 sql 语句：\(sql)")
                
            } else {
                println("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func updateTimestampInConversation(timeStamp: Int, userId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "update \(conversationTableName) set LastUpdateTime = ? where UserId = ?"
            println("执行 updateTimestampInConversation userId: \(userId)")
            var array = [timeStamp, userId]
            if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                println("success 执行 sql 语句：\(sql)")
                
            } else {
                println("error 执行 sql 语句：\(sql)")
            }
        }
    }

    func updateConversationIdInConversation(conversationId: String, userId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "update \(conversationTableName) set ConversationId = ? where UserId = ?"
            println("执行 updateConversationIdInConversation userId: \(userId)")
            var array = [conversationId, userId]
            if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                println("success 执行 sql 语句：\(sql)")
                
            } else {
                println("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func removeConversationfromDB(chatterId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in

            var sql = "delete from \(conversationTableName) where userId = ?"
            dataBase.executeUpdate(sql, withArgumentsInArray: [chatterId])
        }
    }
    
    
}
