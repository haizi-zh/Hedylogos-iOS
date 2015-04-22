//
//  ChatManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/22/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class ChatManager: NSObject {
    
    func selectChatMessageList(chatterId:Int, untilLocalId localId: Int, messageCount: Int) -> NSArray {
        var daoHelper = DaoHelper()
        var tableName = "chat_\(chatterId)"
        var retArray = NSArray()
        if daoHelper.openDB() {
            retArray = daoHelper.selectChatMessageList(tableName, untilLocalId: localId, messageCount: messageCount)
            daoHelper.closeDB()
        }
        return retArray
    }
}
