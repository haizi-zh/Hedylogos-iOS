//
//  DaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/14/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class DaoHelper:NSObject, chatDaoProtocol {
    private let db: FMDatabase
    private let chatMessageDaoHelper: ChatMessageDaoHelper
    private let metaDataDaoHelper: MetaDataDaoHelper
    private let documentPath: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
    
    override init() {
        var dbPath: String = documentPath.stringByAppendingPathComponent("user.sqlite")
        db = FMDatabase(path: dbPath)
        chatMessageDaoHelper = ChatMessageDaoHelper(db: db)
        metaDataDaoHelper = MetaDataDaoHelper(db: db)
        super.init()
    }
    
    func createChatTable(tableName: String) -> Bool {
        return chatMessageDaoHelper.createChatTable(tableName)
    }
    
    func createAudioMessageTable(tableName: String) -> Bool {
        return metaDataDaoHelper.createAudioMessageTable(tableName)
    }
    
    func createImageMessageTable(tableName: String) -> Bool {
        return metaDataDaoHelper.createImageMessageTable(tableName)
    }
    
    func updateChatMessageDataWithName(tableName: String, message:BaseMessage) -> Bool {
        return chatMessageDaoHelper.updateChatMessageDataWithName(tableName, message:message)
    }
    
    func updateMessageServerId(tableName: String, localId:Int, serverId: Int) -> Bool {
        return chatMessageDaoHelper.updateMessageServerId(tableName, localId: localId, serverId: serverId)
    }
}








