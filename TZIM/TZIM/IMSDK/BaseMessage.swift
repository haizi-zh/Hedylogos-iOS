//
//  BaseMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class BaseMessage: NSObject {
    var localId: Int
    var serverId: Int
    var message: String
    var messageType: IMMessageType
    var status: IMMessageStatus
    var createTime: Int
    var sendType: IMMessageSendType
    var chatterId: Int
    
    override init() {
        localId = -1
        serverId = -1
        message = ""
        messageType = .TextMessageType
        status = .IMMessageReaded
        createTime = 0
        sendType = .MessageSendMine
        chatterId = -1
        super.init()
    }
}
