//
//  MessageManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol MessageManagerDelegate {
    /**
    收到新消息
    :param: message 消息内容
    :param: fromUser 消息来自哪里
    */
    func receiveNewMessage(message: BaseMessage, fromUser:String)
}

class MessageManager: NSObject {
    
    private var messageManagerDelegateArray: NSMutableArray = []
    
    private let messageReceiveManager = MessageReceiveManager()
    private let messageSendManager = MessageSendManager()
    
    override init() {
        var tableView = UITableView()
        super.init()
        messageReceiveManager.messageManagerDeleagteArray = messageManagerDelegateArray
    }
    
    func addMessageDelegate(delegate: MessageManagerDelegate) {
        messageManagerDelegateArray.addObject(delegate)
    }
    
    func removeMessageDelegate(delegate: MessageManagerDelegate) {
        for tempDelegate in messageManagerDelegateArray {
            if delegate === tempDelegate {
                messageManagerDelegateArray.removeObject(tempDelegate)
                break
            }
        }
    }

   
}
