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
        retDic.setValue(localId, forKey: "localId")
        retDic.setValue(type, forKey: "type")
        retDic.setValue(message, forKey: "contents")
        retDic.setValue("10001", forKey: "sender")
        retDic.setValue(receiverId, forKey: "receiver")
        return retDic
    }
    
    override init() {
        super.init()
    }
}
