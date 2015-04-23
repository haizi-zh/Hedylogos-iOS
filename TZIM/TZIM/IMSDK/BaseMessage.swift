//
//  BaseMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class BaseMessage: NSObject {
    var localId: Int = -1
    var serverId: Int = -1
    var message: String = ""
    var type: Int = -1
    var status: Int = -1
    var createTime: Int = 0
    var sendType: Int = -1
    var sender: Int = -1
    var reveiver: Int = -1
    
    init(tLocalId: Int, tServerId: Int, tStatus: Int, tCreateTime: Int, tSendType: Int) {
        localId = tLocalId
        serverId = tServerId
        status = tStatus
        createTime = tCreateTime
        sendType = tSendType
        type = 0
        super.init()
    }
    
    func prepareMessage2Send(receiverId: String) ->  NSDictionary{
        var retDic = NSMutableDictionary()
        retDic.setValue(type, forKey: "msgType")
        retDic.setValue(message, forKey: "contents")
        retDic.setValue(1, forKey: "sender")
        retDic.setValue(2, forKey: "receiver")
        return retDic
    }
    
    override init() {
        super.init()
    }
}
