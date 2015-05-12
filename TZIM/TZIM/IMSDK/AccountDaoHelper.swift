//
//  AccountDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 5/12/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol AccountDaoProtocol {
    func createAccountTable()
    func insertAccountInfo2DB(account: AccountModel)
    func loadAccountFromDB() -> AccountModel?
}

class AccountDaoHelper:NSObject, AccountDaoProtocol {
    
    private let dataBase: FMDatabase
    private let databaseQueue: FMDatabaseQueue
    
    override init() {
        var dbPath: String = documentPath.stringByAppendingPathComponent("AccountDB/Account.sqlite")
        
        println("dbPath: \(dbPath)")
        
        var fileManager =  NSFileManager()
        
        if !fileManager.fileExistsAtPath(dbPath) {
            var directryPath = documentPath.stringByAppendingPathComponent("AccountDB")
            fileManager.createDirectoryAtPath(directryPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        self.dataBase = FMDatabase(path: dbPath)
        self.databaseQueue = FMDatabaseQueue(path: dbPath)
    }
    
    func createAccountTable() {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "create table '\(accountTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, NickName TEXT, Avatar Text, AvatarSmall Text, ShortPY Text, FullPY Text, Signature Text, Memo Text, Sex INTEGER, ExtData Text)"
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                println("success 执行 sql 语句：\(sql)")
                
            } else {
                println("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    /**
    插入用户信息到数据库
    
    :param: account
    */
    func insertAccountInfo2DB(account: AccountModel) {
        if !self.tableIsExit(accountTableName) {
            self.createAccountTable()
        }
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "insert or replace into \(accountTableName) (UserId, NickName, Avatar, AvatarSmall, ShortPY, FullPY, Signature, Memo, Sex) values (?,?,?,?,?,?,?,?,?)"
            println("执行 sql 语句：\(sql)")
            var array = [account.userId, account.nickName, account.avatar, account.avatarSmall, account.shortPY, account.fullPY, account.signature, account.memo, account.sex]
            dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
        }
        
    }
    
    func loadAccountFromDB() -> AccountModel? {
        var account: AccountModel!
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "select * from \(accountTableName)"
            println("执行 sql 语句：\(sql)")
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
            if (rs != nil) {
                while rs.next() {
                    account = AccountModel()
                    account.userId = Int(rs.intForColumn("UserId"))
                    account.nickName = rs.stringForColumn("NickName")
                    account.avatar = rs.stringForColumn("Avatar")
                    account.avatarSmall = rs.stringForColumn("AvatarSmall")
                    account.signature = rs.stringForColumn("Signature")
                    account.sex = Int(rs.intForColumn("Sex"))
                    account.memo = rs.stringForColumn("memo")
                }
            }
        }
        return account
    }
    
    private func tableIsExit(tableName: String) -> Bool {
        
        var retResult = false
        
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            
            var sql = "select count(*) as 'count' from sqlite_master where type ='table' and name = ?"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: [tableName])
            if (rs != nil) {
                while (rs.next())
                {
                    var count: Int32 = rs.intForColumn("count")
                    if (0 == count) {
                        retResult =  false;
                    } else {
                        retResult =  true;
                    }
                }
            }
        }
        return retResult;
    }

}
