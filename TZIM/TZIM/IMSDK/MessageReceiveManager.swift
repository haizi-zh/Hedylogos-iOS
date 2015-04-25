//
//  MessageReceiveManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class MessageReceiveManager: MessageTransferManager, PushMessageDelegate {
    let pushSDKManager = PushSDKManager.shareInstance()
    
    override init() {
        super.init()
        pushSDKManager.pushMessageDelegate = self
    }
    
    //MARK: PushMessageDelegate
    func receivePushMessage(message: NSString) {
        println("收到消息：\(message)")
        var message = MessageManager.messageModelWithMessage(message)
        message?.sendType = .MessageSendSomeoneElse
        destributionMessage(message)
    }
    
    //MARK: private method
    func destributionMessage(message: BaseMessage?) {
        if let message = message {
            switch message {
            case let textMsg as TextMessage:
                for messageManagerDelegate in super.messageTransferManagerDelegateArray {
                    (messageManagerDelegate as! MessageTransferManagerDelegate).receiveNewMessage?(message)
                }
            default:
                break
            }
            let daoHelper = DaoHelper()
            if daoHelper.openDB() {
                var tableName = "chat_\(message.chatterId)"
                daoHelper.insertChatMessage(tableName, message: message)
                daoHelper.closeDB()
            }
        }
    }
}
