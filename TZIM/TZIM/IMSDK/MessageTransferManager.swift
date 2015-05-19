//
//  MessageManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol MessageTransferManagerDelegate {
    /**
    收到新消息
    :param: message 消息内容
    */
    optional func receiveNewMessage(message: BaseMessage)
    
    /**
    发送新消息
    :param: message
    */
    optional func sendNewMessage(message: BaseMessage)
    
    /**
    发送的消息已经发送成功
    :param: message 发送成功的消息
    */
    optional func messageHasSended(message: BaseMessage)
}

class MessageTransferManager: NSObject {
    
    var messageTransferManagerDelegateArray: NSMutableArray = []
    
    override init() {
        var tableView = UITableView()
        super.init()
    }
    
    /**
    添加消息的监听者
    :param: delegate 需要监听消息的
    */
    func addMessageDelegate(delegate: MessageTransferManagerDelegate) {
        messageTransferManagerDelegateArray.addObject(delegate)
    }
    
    /**
    移除消息的监听者
    :param: delegate 不需要监听消息的
    */
    func removeMessageDelegate(delegate: MessageTransferManagerDelegate) {
        for tempDelegate in messageTransferManagerDelegateArray {
            if delegate === tempDelegate {
                messageTransferManagerDelegateArray.removeObject(tempDelegate)
                break
            }
        }
    }
   
}





