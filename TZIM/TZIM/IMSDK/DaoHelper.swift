//
//  DaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/14/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class DaoHelper:NSObject, chatDaoProtocol, UserDaoProtocol, ConversationDaoProtocol {
    private let db: FMDatabase
    private let queue: FMDatabaseQueue
    

    private let chatMessageDaoHelper: ChatMessageDaoHelper
    private let metaDataDaoHelper: MetaDataDaoHelper
    private let userDaoHelper: UserDaoHelper
    private let conversationHelper: ConversationDaoHelper
    
    private let documentPath: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
    
    override init() {
        var dbPath: String = documentPath.stringByAppendingPathComponent("user.sqlite")
        db = FMDatabase(path: dbPath)
        queue = FMDatabaseQueue(path: dbPath)
        
        chatMessageDaoHelper = ChatMessageDaoHelper(db: db)
        metaDataDaoHelper = MetaDataDaoHelper(db: db)
        userDaoHelper = UserDaoHelper(db: db)
        conversationHelper = ConversationDaoHelper(db: db)
        super.init()
    }
    
    func openDB() -> Bool {
        return db.open()
    }
    
    func closeDB() -> Bool {
        return db.close()
    }
    
    func createChatTable(tableName: String) -> Bool {
        return chatMessageDaoHelper.createChatTable(tableName)
    }
    
    func createAudioMessageTable(tableName: String) -> Bool {
        return metaDataDaoHelper.createAudioMessageTable(tableName)
    }
    
    func updateChatMessageDataWithName(tableName: String, message:BaseMessage) -> Bool {
        return chatMessageDaoHelper.updateChatMessageDataWithName(tableName, message:message)
    }
    
    func updateMessageServerId(tableName: String, localId:Int, serverId: Int) -> Bool {
        return chatMessageDaoHelper.updateMessageServerId(tableName, localId: localId, serverId: serverId)
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








