//
//  DaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/14/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let documentPath: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String

public class DaoHelper:NSObject, ChatDaoProtocol, UserDaoProtocol, ConversationDaoProtocol {
    private let db: FMDatabase
    private let chatMessageDaoHelper: ChatMessageDaoHelper
    private let metaDataDaoHelper: MetaDataDaoHelper
    private let userDaoHelper: UserDaoHelper
    private let conversationHelper: ConversationDaoHelper
    
    override init() {
        
        var userId = AccountManager.shareInstance().userId
        
        var dbPath: String = documentPath.stringByAppendingPathComponent("\(userId)/user.sqlite")
        var fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(dbPath) {
            var directryPath = documentPath.stringByAppendingPathComponent("\(userId)")
            fileManager.createDirectoryAtPath(directryPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        db = FMDatabase(path: dbPath)
        chatMessageDaoHelper = ChatMessageDaoHelper(db: db)
        metaDataDaoHelper = MetaDataDaoHelper(db: db)
        userDaoHelper = UserDaoHelper(db: db)
        conversationHelper = ConversationDaoHelper(db: db)
        super.init()
    }
    
    /**
    测试的时候获取 database
    */
    func getDB4Test()-> FMDatabase {
        return db
    }
    
    func openDB() -> Bool {
        return db.open()
    }
    
    func closeDB() -> Bool {
        return db.close()
    }
    
    //MARK:ChatMessageDaoHelperProtocol
    func createChatTable(tableName: String) -> Bool {
        return chatMessageDaoHelper.createChatTable(tableName)
    }
    
    func createAudioMessageTable(tableName: String) -> Bool {
        return metaDataDaoHelper.createAudioMessageTable(tableName)
    }
    
    func insertChatMessage(tableName: String, message:BaseMessage) -> Bool {
        return chatMessageDaoHelper.insertChatMessage(tableName, message:message)
    }
    
    func updateMessageServerId(tableName: String, localId:Int, serverId: Int) -> Bool {
        return chatMessageDaoHelper.updateMessageServerId(tableName, localId: localId, serverId: serverId)
    }
    
    func selectChatMessageList(fromTable:String, untilLocalId: Int, messageCount: Int) -> NSArray {
        return chatMessageDaoHelper.selectChatMessageList(fromTable, untilLocalId: untilLocalId, messageCount: messageCount)
    }
    
    //MARK:UserDaoProtocol
    func createFrendTable() -> Bool {
        return userDaoHelper.createFrendTable()
    }
    
    func deleteFrendTable() {
        return userDaoHelper.deleteFrendTable()
    }
    
    func addFrend2DB(frend: FrendModel) -> Bool {
        return userDaoHelper.addFrend2DB(frend)
    }
    
    func selectAllContacts() -> NSArray {
        return userDaoHelper.selectAllContacts()
    }
    
    //MARK: ConversationDaoProtocol 
    func createConversationsTable() -> Bool {
        return conversationHelper.createConversationsTable()
    }
    
    func addConversation(userId: Int, lastUpdateTime: Int) {
        return conversationHelper.addConversation(userId, lastUpdateTime: lastUpdateTime)
    }
    
    func getAllConversationList() -> NSArray {
        return conversationHelper.getAllConversationList()
    }
    
}








