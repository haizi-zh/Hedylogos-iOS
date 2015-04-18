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
    func updateChatMessageDataWithName(tableName: String, message:BaseMessage) -> Bool
    func updateMessageServerId(tableName: String, localId:Int, serverId: Int) -> Bool 
}

class ChatMessageDaoHelper: ChatMessageDaoHelperProtocol{
    private let dataBase: FMDatabase
    init(db: FMDatabase) {
        dataBase = db
    }
    
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
        var sql = "create table '\(tableName)' (LocalId INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, ServerId INTEGER, Status int(4), Type int(4), Message TEXT, CreateTime INTEGER, SendType int, MetaId INTEGER)"
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
    func updateChatMessageDataWithName(tableName: String, message:BaseMessage) -> Bool {
        if dataBase.open() {
            if !BaseDaoHelper.tableIsExit(tableName, db: dataBase) {
                self.createChatTable(tableName)
            }
            var sql = "insert into \(tableName) (ServerId, Status, Type, Message, CreateTime, SendType) values (?,?,?,?,?,?)"
            var array = [message.serverId, message.status, message.type, message.messageContent, message.createTime, message.sendType]
            if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                dataBase.close()
                println("执行 sql 语句：\(sql)")
                return true
            }
            dataBase.close()
            return false
        }
        return false
    }
    
    /**
    更新表的 serverId
    
    :param: tableName 需要更新的表
    :param: serverId  需要更新的记录
    
    :returns: 是否更新成功
    */
    func updateMessageServerId(tableName: String, localId:Int, serverId: Int) -> Bool {
        if dataBase.open() {
            if !BaseDaoHelper.tableIsExit(tableName, db: dataBase) {
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
}






