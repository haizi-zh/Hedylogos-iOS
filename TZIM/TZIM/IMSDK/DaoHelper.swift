//
//  DaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/14/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let daoHelper = DaoHelper()

let documentPath: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
let tempDirectory: String = NSTemporaryDirectory()

let databaseWriteQueue = dispatch_queue_create("com.database.write", nil)

public class DaoHelper:NSObject {
    private let db: FMDatabase
    private let chatMessageDaoHelper: ChatMessageDaoHelper
    private let metaDataDaoHelper: MetaDataDaoHelper
    private let userDaoHelper: UserDaoHelper
    private let conversationHelper: ConversationDaoHelper
    private let dbQueue: FMDatabaseQueue
    
    class func shareInstance() -> DaoHelper {
        return daoHelper
    }
    
    override init() {
        
        var userId = AccountManager.shareInstance().userId
        
        var dbPath: String = documentPath.stringByAppendingPathComponent("\(userId)/user.sqlite")
        
        println("dbPath: \(dbPath)")
                
        var fileManager =  NSFileManager()
        
        if !fileManager.fileExistsAtPath(dbPath) {
            var directryPath = documentPath.stringByAppendingPathComponent("\(userId)")
            fileManager.createDirectoryAtPath(directryPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        db = FMDatabase(path: dbPath)
        dbQueue = FMDatabaseQueue(path: dbPath)

        chatMessageDaoHelper = ChatMessageDaoHelper(db: db, dbQueue: dbQueue)
        metaDataDaoHelper = MetaDataDaoHelper(db: db)
        userDaoHelper = UserDaoHelper(db: db, dbQueue: dbQueue)
        conversationHelper = ConversationDaoHelper(db: db, dbQueue: dbQueue)
        super.init()
    }
    
    /**
    测试的时候获取 database
    */
    func getDB4Test()-> FMDatabase {
        return db
    }
    
    private func openDB() -> Bool {
        return db.open()
    }
    
    private func closeDB() -> Bool {
        return db.close()
    }
    
    //MARK:ChatMessageDaoHelperProtocol
    
    func createChatTable(tableName: String) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.chatMessageDaoHelper.createChatTable(tableName)
            self.closeDB()
        })
    }
    
    func createAudioMessageTable(tableName: String) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.metaDataDaoHelper.createAudioMessageTable(tableName)
            self.closeDB()
        })
    }
    
    func insertChatMessage(tableName: String, message:BaseMessage) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.chatMessageDaoHelper.insertChatMessage(tableName, message:message)
            self.closeDB()
        })
    }
    
    func insertChatMessageList(messageList: Array<BaseMessage>, completionBlock:()->()) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.chatMessageDaoHelper.insertChatMessageList(messageList)
            self.closeDB()
            completionBlock()
        })
    }
    
    func updateMessageInDB(tableName: String, message:BaseMessage) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.chatMessageDaoHelper.updateMessageInDB(tableName, message: message)
            self.closeDB()
        })
    }
    
    func selectChatMessageList(fromTable:String, untilLocalId: Int, messageCount: Int) -> NSArray {
        if self.openDB() {
            var result = chatMessageDaoHelper.selectChatMessageList(fromTable, untilLocalId: untilLocalId, messageCount: messageCount)
            self.closeDB()
            return result
            
        } else {
            return NSArray()
        }
    }
    
    func selectLastServerMessage(fromTable: String) -> BaseMessage? {
        if self.openDB() {
            var result = chatMessageDaoHelper.selectLastServerMessage(fromTable)
            self.closeDB()
            return result
        }
        return nil
    }
    
    func selectLastLocalMessageInChatTable(tableName: NSString) -> BaseMessage? {
        if self.openDB() {
            var result = chatMessageDaoHelper.selectLastLocalMessageInChatTable(tableName)
            self.closeDB()
            return result
        }
        return nil
    }
    
    func selectAllLastServerChatMessageInDB() -> NSDictionary {
        if self.openDB() {
            var result =  chatMessageDaoHelper.selectAllLastServerChatMessageInDB()
            self.closeDB()
            return result
            
        } else {
            return NSDictionary()
        }
    }

    /**
    消息在数据库里是否存在
    
    :param: tableName 消息所在的表
    :param: message   消息内容
    
    :returns: true：存在     false：不存在
    */
    func messageIsExitInTable(tableName: String, message: BaseMessage) -> Bool {
        if self.openDB() {
            var result = chatMessageDaoHelper.messageIsExitInTable(tableName, message: message)
            self.closeDB()
            return result

        } else {
            return false
        }
    }
    
    func updateMessageContents(tableName: String, message: BaseMessage) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.chatMessageDaoHelper.updateMessageContents(tableName, message: message)
            self.closeDB()
        })
    }

    
    //MARK:UserDaoProtocol
    func createFrendTable() {

        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.userDaoHelper.createFrendTable()
            self.closeDB()
        })
    }
    
    func deleteFrendTable() {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.userDaoHelper.deleteFrendTable()
            self.closeDB()
        })
       
    }
    
    func addFrend2DB(frend: FrendModel) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.userDaoHelper.addFrend2DB(frend)
            self.closeDB()
        })
    }
    
    func selectAllContacts() -> NSArray {
        if self.openDB() {
            var result = userDaoHelper.selectAllContacts()
            self.closeDB()
            return result
            
        } else {
            return NSArray()
        }
    }
    
    //MARK: ConversationDaoProtocol 
    func createConversationsTable() {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.conversationHelper.createConversationsTable()
            self.closeDB()

        })
    }
    
    func addConversation(conversation :ChatConversation) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.conversationHelper.addConversation(conversation)
            self.closeDB()
        })

    }
    
    func getAllConversationList() -> NSArray {
        if self.openDB() {
            var retArray = conversationHelper.getAllConversationList()
            self.closeDB()
            return retArray
            
        } else {
            return NSArray()
        }
    }
    
    func removeConversationfromDB(chatterId: Int) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.conversationHelper.removeConversationfromDB(chatterId)
            self.closeDB()
        })
    }
    
}

