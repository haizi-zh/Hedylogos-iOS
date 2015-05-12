//
//  UserDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/20/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let frendTableName = "Frend"
let accountTableName = "Account"

protocol FrendDaoProtocol {
    
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
    func selectAllContacts() -> Array<FrendModel>
    
    /**
    frend是否在数据库里存在
    :param: userId
    :returns:
    */
    func frendIsExitInDB(userId: Int) -> Bool
    
    /**
    获取我所有的群组列表
    
    :returns:
    */
    func selectAllGroup() -> Array<IMGroupModel>
    
}

class FrendDaoHelper: BaseDaoHelper, FrendDaoProtocol {
    
    /**
    创建 frend 表，frend 表存的是所有好友和非好友的人。利用 type 来区分类型
    :returns:
    */
    
    class func createFrendTable(DB: FMDatabase) -> Bool {
        
        var sql = "create table '\(frendTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, NickName TEXT, Avatar Text, AvatarSmall Text, ShortPY Text, FullPY Text, Signature Text, Memo Text, Sex INTEGER, Type INTEGER, ExtData Text)"
        if (DB.executeUpdate(sql, withArgumentsInArray: nil)) {
            println("执行 sql 语句：\(sql)")
            return true
        }
        return false
    }
    
    func createFrendTable() {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "create table '\(frendTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, NickName TEXT, Avatar Text, AvatarSmall Text, ShortPY Text, FullPY Text, Signature Text, Memo Text, Sex INTEGER, Type INTEGER, ExtData Text)"
            if (super.dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                println("success 执行 sql 语句：\(sql)")
                
            } else {
                println("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func deleteFrendTable() {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in

            var sql = "drop table Frend"
            dataBase.executeUpdate(sql, withArgumentsInArray: nil)
        }
    }
    
    func addFrend2DB(frend: FrendModel) {
        if !super.tableIsExit(frendTableName) {
            createFrendTable()
        }
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in

            var sql = "insert or replace into \(frendTableName) (UserId, NickName, Avatar, AvatarSmall, ShortPY, FullPY, Signature, Memo, Sex, Type) values (?,?,?,?,?,?,?,?,?,?)"
            println("执行 sql 语句：\(sql)")
            var array = [frend.userId, frend.nickName, frend.avatar, frend.avatarSmall, frend.shortPY, frend.fullPY, frend.signature, frend.memo, frend.sex, frend.type.rawValue]
            dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
        }
    }
    
    /**
    获取所有的是我的好友的列表
    :returns:
    */
    func selectAllContacts() -> Array<FrendModel> {
        var retArray = Array<FrendModel>()
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "select * from \(frendTableName) where Type = ?"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: [IMFrendType.Frend.rawValue])
            if (rs != nil) {
                while rs.next() {
                    var frend = FrendModel()
                    frend.userId = Int(rs.intForColumn("UserId"))
                    frend.nickName = rs.stringForColumn("NickName")
                    frend.avatar = rs.stringForColumn("Avatar")
                    frend.avatarSmall = rs.stringForColumn("AvatarSmall")
                    frend.signature = rs.stringForColumn("Signature")
                    frend.sex = Int(rs.intForColumn("Sex"))
                    frend.type = IMFrendType(rawValue: Int(rs.intForColumn("Type")))!
                    frend.memo = rs.stringForColumn("memo")
                    retArray.append(frend)
                }
            }
        }
        return retArray
    }
    
    func frendIsExitInDB(userId: Int) -> Bool {
        var sql = "select * from \(frendTableName) where userId = ?"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: [userId])
        if (rs != nil) {
            while rs.next() {
               return true
            }
        }
        return false
    }
    
    
    //MARK: Group
    
    /**
    获取所有的是我的群组 的列表
    :returns:
    */
    func selectAllGroup() -> Array<IMGroupModel> {
        var retArray = Array<IMGroupModel>()
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "select * from \(frendTableName) where Type = ?"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: [IMFrendType.Frend.rawValue])
            if (rs != nil) {
                while rs.next() {
                    var group = IMGroupModel()
                    group.groupId = Int(rs.intForColumn("UserId"))
                    group.subject = rs.stringForColumn("NickName")
                    retArray.append(group)
                }
            }
        }
        return retArray
    }

}





