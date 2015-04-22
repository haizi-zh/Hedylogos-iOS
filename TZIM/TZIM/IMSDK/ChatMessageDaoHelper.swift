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
    func updateMessageServerId(tableName: String, localId:Int, serverId: Int) -> Bool
    
    /**
    按条件获取聊天列表
    :param: fromTable    获取聊天信息的表
    :param: untilLocalId 获取到哪条localid
    :param: messageCount 需要获取的数量
    :returns: 获取到的聊天信息
    */
    func selectChatMessageList(fromTable:String, untilLocalId: Int, messageCount: Int) -> NSArray 
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
        var array = [message.serverId, message.status, message.type, message.message, message.createTime, message.sendType]
        if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
            println("执行 sql 语句：\(sql)")
            return true
        } else {
            return false
        }
    }
    
    /**
    更新表的 serverId
    :param: tableName 需要更新的表
    :param: serverId  需要更新的记录
    :returns: 是否更新成功
    */
    func updateMessageServerId(tableName: String, localId:Int, serverId: Int) -> Bool {
        if dataBase.open() {
            if !super.tableIsExit(tableName) {
                self.createChatTable(tableName)
            }
            var sql = "update \(tableName) set serverId = ? where localId = ?"
            if dataBase.executeUpdate(sql, withArgumentsInArray:[serverId, localId]) {
                dataBase.close()
                println("执行 sql 语句：\(sql)")
                return true
            }
            dataBase.close()
            return false
        }
        return false
    }
    
    func selectChatMessageList(fromTable:String, untilLocalId: Int, messageCount: Int) -> NSArray {
        var retArray = NSMutableArray()
        var sql = "select * from (select * from \(fromTable) where LocalId < ? order by LocalId desc limit \(messageCount)) order by LocalId"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: [untilLocalId, messageCount])

        if (rs != nil) {
            while rs.next() {
                var message = BaseMessage()
                message.message = rs.stringForColumn("Message")
                message.sendType = Int(rs.intForColumn("SendType"))
                message.createTime = Int(rs.intForColumn("CreateTime"))
                message.localId = Int(rs.intForColumn("LocalId"))
                retArray.addObject(message)
            }
        }
        return retArray
    }
}










