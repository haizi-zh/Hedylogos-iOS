//
//  ChatMessageDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/14/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol ChatMessageDaoHelperProtocol{
    func createChatTable(tableName: String) -> Bool
    func insertChatMessage(tableName: String, message:BaseMessage) -> Bool
    func updateMessageInDB(tableName: String, message:BaseMessage) -> Bool 
    
    /**
    按条件获取聊天列表
    :param: fromTable    获取聊天信息的表
    :param: untilLocalId 获取到哪条localid
    :param: messageCount 需要获取的数量
    :returns: 获取到的聊天信息
    */
    func selectChatMessageList(fromTable:String, untilLocalId: Int, messageCount: Int) -> NSArray
    
    func selectAllLastChatMessageInDB() -> NSArray
}

class ChatMessageDaoHelper:BaseDaoHelper, ChatMessageDaoHelperProtocol{
    
    /**
    当数据库没打开的时候创建聊天表
    :param: tableName 表名
    :returns: 创建是否成功
    */
    func createChatTableWithoutOpen(tableName: String) -> Bool {
        if dataBase.open() {
           return self.createChatTable(tableName)
        }
        return false
    }
    
    /**
    当数据库打开的时候创建表，就不需要重新打开数据库了
    :param: tableName 表明
    :returns: 创建是否成功
    */
    func createChatTable(tableName: String) -> Bool {
        var sql = "create table '\(tableName)' (LocalId INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, ServerId INTEGER, Status int(4), Type int(4), Message TEXT, CreateTime INTEGER, SendType int)"
        if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
            println("执行 sql 语句：\(sql)")
            return true
        } else {
            return false
        }
    }
    
    /**
    更新聊天表数据
    :param: table 表明
    :returns: 更新是否成功
    */
    func insertChatMessage(tableName: String, message:BaseMessage) -> Bool {
        if !super.tableIsExit(tableName) {
            self.createChatTable(tableName)
        }
        var sql = "insert into \(tableName) (ServerId, Status, Type, Message, CreateTime, SendType) values (?,?,?,?,?,?)"
        var array = [message.serverId, message.status.rawValue, message.messageType.rawValue, message.message, message.createTime, message.sendType.rawValue]
        if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
            println("执行 sql 语句：\(sql)")
            message.localId = Int(dataBase.lastInsertRowId())
            return true
        } else {
            return false
        }
    }
    
    /**
    更新表的 serverId
    :param: tableName 需要更新的表
    :param: message 更新内容
    :returns: 是否更新成功
    */
    func updateMessageInDB(tableName: String, message:BaseMessage) -> Bool {
        if !super.tableIsExit(tableName) {
            self.createChatTable(tableName)
        }
        var sql = "update \(tableName) set ServerId = ?, Status = ?  where LocalId = ?"
        if dataBase.executeUpdate(sql, withArgumentsInArray:[message.serverId, message.status.rawValue, message.localId]) {
            dataBase.close()
            println("执行 sql 语句：\(sql)")
            return true
        }
        return false
    }
    
    func selectChatMessageList(fromTable:String, untilLocalId: Int, messageCount: Int) -> NSArray {
        var retArray = NSMutableArray()
        var sql = "select * from (select * from \(fromTable) where LocalId < ? order by LocalId desc limit \(messageCount)) order by LocalId"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: [untilLocalId, messageCount])
        if (rs != nil) {
            while rs.next() {
                if let message = ChatMessageDaoHelper.messageModelWithFMResultSet(rs) {
                    retArray.addObject(message)
                }
            }
        }
        return retArray
    }
    
    /**
    取到最后一条与服务器同步的消息
    :param: fromTable
    :returns:
    */
    func selectLastServerMessage(fromTable:String) -> BaseMessage? {
        var retArray = NSMutableArray()
        var sql = "select * from \(fromTable) where serverId >= 0 order by LocalId desc limit 1"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
        if (rs != nil) {
            while rs.next() {
                if let message = ChatMessageDaoHelper.messageModelWithFMResultSet(rs) {
                    return message
                }
            }
        }
        return nil
    }

    
    /**
    获取所有的聊天列表里的最后一条消息
    :returns:
    */
    func selectAllLastChatMessageInDB() -> NSArray {
        var retArray = NSMutableArray()
        var allTables = super.selectAllTableName(keyWord: "chat")
        for tableName in allTables {
            var message = selectLastServerMessage(tableName as! String)
            if let message = message {
                retArray.addObject([message.chatterId: message.serverId])
            }
        }
        return retArray
    }
    
    
//MARK: class methods
    
    /**
    将数据库的查询结果转为 messagemodel
    :param: rs 数据库查询结果
    :returns: 转换的message model
    */
    class func messageModelWithFMResultSet(rs: FMResultSet) -> BaseMessage? {
        var retMessage: BaseMessage?
        if let messageType = IMMessageType(rawValue: Int(rs.intForColumn("Type"))) {
            switch messageType {
            case .TextMessageType:
                retMessage = TextMessage()
                retMessage?.message = rs.stringForColumn("Message")
                
            case .AudioMessageType:
                retMessage = AudioMessage()
                
            case .ImageMessageType:
                retMessage = ImageMessage()
                var contents = rs.stringForColumn("Message")
                if let contentsData = contents.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
                    if let contentJson = NSJSONSerialization.JSONObjectWithData(contentsData, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary {
                        (retMessage as! ImageMessage).HDUrl = contentJson.objectForKey("url") as? String
                    }
                }
                
            case .LocationMessageType:
                retMessage = LocationMessage()
            
            default:
                break
            }
            
            retMessage?.sendType = IMMessageSendType(rawValue: Int(rs.intForColumn("SendType")))!
            retMessage?.createTime = Int(rs.intForColumn("CreateTime"))
            retMessage?.localId = Int(rs.intForColumn("LocalId"))
            retMessage?.serverId = Int(rs.intForColumn("ServerId"))
            if let status = IMMessageStatus(rawValue: Int(rs.intForColumn("status"))) {
                retMessage?.status = status
            }
        }
        return retMessage
    }
}


















