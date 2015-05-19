//
//  CMDMessageManager.swift
//  TZIM
//
//  Created by liangpengshuai on 5/19/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

enum CMDMessageRoutingKey: Int {
    case Frend_CMD              = 1       //好友相关的 cmd 消息
    case DiscussionGroup_CMD    = 2       //讨论组相关的 cmd 消息
    case Group_CMD              = 3       //群组相关的 cmd 消息
}

@objc protocol CMDMessageManagerDelegate {
    
}

class CMDMessageManager: NSObject {
    
    private var listenerQueue: Array<[CMDMessageRoutingKey: CMDMessageManager]> = Array()

    /**
    注册消息的监听
    
    :param: monitor        监听的对象
    :param: withRoutingKey 需要监听消息的key
    */
    func addPushMessageListener(listener: CMDMessageManager, withRoutingKey routingKey: CMDMessageRoutingKey) {
        listenerQueue.append([routingKey: listener])
    }
    
    /**
    移除消息的监听者
    
    :param: listener   监听对象
    :param: routingKey 监听消息的 key
    */
    func removePushMessageListener(listener: CMDMessageManager, withRoutingKey routingKey: CMDMessageRoutingKey) {
        for (value, index) in enumerate(listenerQueue) {
            if value[routingKey] == listener {
                listenerQueue.removeAtIndex(index)
                return
            }
        }
    }

   
}
