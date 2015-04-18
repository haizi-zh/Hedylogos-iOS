//
//  BaseMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class BaseMessage: NSObject {
    var localId: Int!
    var serverId: Int = -1
    var messageContent: String = ""
    var type: Int = -1
    var status: Int = -1
    var createTime: Int = 0
    var sendType: Int = -1
    
    init(tLocalId: Int, tServerId: Int, tStatus: Int, tCreateTime: Int, tSendType: Int) {
        localId = tLocalId
        serverId = tServerId
        status = tStatus
        createTime = tCreateTime
        sendType = tSendType
        type = 0
        super.init()
    }
    
    override init() {
        super.init()
    }
}
