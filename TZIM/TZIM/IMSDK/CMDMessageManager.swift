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
    
    //MARK: 好友
    
    /**
    请求添加好友
    
    :param: requestContent 请求的信息
    */
    optional func requestAddFrend(requestContent: NSDictionary)
    
    //MARK: 讨论组
    
    /**
    邀请加入讨论组
    
    :param: inviteContent 邀请的内容
    */
    optional func inviteAddDiscussionGroup(inviteContent: NSDictionary)
    
    /**
    某人退出了讨论组
    
    :param: content
    */
    optional func someoneQuiteDiscussionGroup(content: NSDictionary)
    
    
    
    //MARK: 群组
    
    /**
    邀请加入群组
    
    :param: inviteContent 邀请的内容
    */
    optional func inviteAddGroup(inviteContent: NSDictionary)
    
    /**
    某人退出了群组
    
    :param: content
    */
    optional func someoneQuiteGroup(content: NSDictionary)
    
    /**
    群组被销毁
    
    :param: content
    */
    optional func groupDestroyed(content: NSDictionary)
    
    
    
}

private let manager = CMDMessageManager()

class CMDMessageManager: NSObject, MessageReceiveManagerDelegate {
    
    private var listenerQueue: Array<[CMDMessageRoutingKey: CMDMessageManager]> = Array()
    
    class func shareInstance() -> CMDMessageManager {
        return manager
    }

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
        for (index, value) in enumerate(listenerQueue) {
            if value[routingKey] === listener {
                listenerQueue.removeAtIndex(index)
                return
            }
        }
    }
    
    
    //MARK: MessageTransferManagerDelegate
    
    func receiveNewMessage(message: BaseMessage) {
        
    }
    

   
}
