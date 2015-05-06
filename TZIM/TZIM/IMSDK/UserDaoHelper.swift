//
//  UserDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/20/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let frendTableName = "Frend"

protocol UserDaoProtocol {
    
    /**
    创建好友表
    :returns:
    */
    func createFrendTable()
    
    /**
    删除好友表
    :returns: 
    */
    func deleteFrendTable()
    
    /**
    添加一个联系人到数据库里
    :param: frend
    :returns:
    */
    func addFrend2DB(frend: FrendModel)
    
    /**
    获取所有的是我的好友的列表
    :returns:
    */
    func selectAllContacts() -> NSArray
    
}

class UserDaoHelper: BaseDaoHelper, UserDaoProtocol {
    
    /**
    创建 frend 表，frend 表存的是所有好友和非好友的人。利用 type 来区分类型
    :returns:
    */
    
    class func createFrendTable(DB: FMDatabase) -> Bool {
        var sql = "create table '\(frendTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, NickName TEXT, Avatar Text, AvatarSmall Text, ShortPY Text, FullPY Text, Signature Text, Memo Text, Sex INTEGER, Type INTEGER)"
        if (DB.executeUpdate(sql, withArgumentsInArray: nil)) {
            println("执行 sql 语句：\(sql)")
            return true
        }
        return false
    }
    
    func createFrendTable() {
        var sql = "create table '\(frendTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, NickName TEXT, Avatar Text, AvatarSmall Text, ShortPY Text, FullPY Text, Signature Text, Memo Text, Sex INTEGER, Type INTEGER)"
        if (super.dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
            println("success 执行 sql 语句：\(sql)")
            
        } else {
            println("error 执行 sql 语句：\(sql)")
        }
    }
    
    func deleteFrendTable() {
        var sql = "drop table Frend"
        dataBase.executeUpdate(sql, withArgumentsInArray: nil)
    }
    
    func addFrend2DB(frend: FrendModel) {
        if !super.tableIsExit(frendTableName) {
            createFrendTable()
        }
        var sql = "insert into \(frendTableName) (UserId, NickName, Avatar, AvatarSmall, ShortPY, FullPY, Signature, Memo, Sex, Type) values (?,?,?,?,?,?,?,?,?,?)"
        println("执行 sql 语句：\(sql)")
        var array = [frend.userId, frend.nickName, frend.avatar, frend.avatarSmall, frend.shortPY, frend.fullPY, frend.signature, frend.memo, frend.sex, frend.type]
        dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
    }
    
    /**
    获取所有的是我的好友的列表
    :returns:
    */
    func selectAllContacts() -> NSArray {
        var retArray = NSMutableArray()
        var sql = "select * from \(frendTableName) where Type = ?"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: [1])
        if (rs != nil) {
            while rs.next() {
                var frend = FrendModel()
                frend.userId = Int(rs.intForColumn("UserId"))
                frend.nickName = rs.stringForColumn("NickName")
                frend.avatar = rs.stringForColumn("Avatar")
                frend.avatarSmall = rs.stringForColumn("AvatarSmall")
                frend.signature = rs.stringForColumn("Signature")
                frend.sex = Int(rs.intForColumn("Sex"))
                frend.type = Int(rs.intForColumn("Type"))
                frend.memo = rs.stringForColumn("memo")
                retArray.addObject(frend)
            }
        }
        
        return retArray
    }
}
