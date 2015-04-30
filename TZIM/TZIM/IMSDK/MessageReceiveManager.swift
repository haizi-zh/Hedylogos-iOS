//
//  MessageReceiveManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let messageReceiveManager = MessageReceiveManager()

class MessageReceiveManager: MessageTransferManager, PushMessageDelegate, MessageReceivePoolDelegate {
    let pushSDKManager = PushSDKManager.shareInstance()
    let messagePool = MessageReceivePool.shareInstance()
    let allLastMessageList: NSMutableArray

    class func shareInstance() -> MessageReceiveManager {
        return messageReceiveManager
    }
    
    override init() {
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            allLastMessageList = daoHelper.selectAllLastChatMessageInDB().mutableCopy() as! NSMutableArray
            daoHelper.closeDB()
        } else {
            allLastMessageList = NSMutableArray()
        }
        super.init()
        pushSDKManager.pushMessageDelegate = self
        messagePool.delegate = self
    }
    
//MARK: private method
    
    private func checkMessages(messageList: NSDictionary) {
        for messageList in messageList.allValues {
            for message in (messageList as! NSMutableArray) {
                
                
                
                
            }
        }
    }
    
    /**
    将合法的消息分发出去
    :param: message
    */
    private func distributionMessage(message: BaseMessage?) {
        if let message = message {
            let daoHelper = DaoHelper()
            if daoHelper.openDB() {
                var tableName = "chat_\(message.chatterId)"
                daoHelper.insertChatMessage(tableName, message: message)
                daoHelper.closeDB()
            }
            switch message {
            case let textMsg as TextMessage:
                for messageManagerDelegate in super.messageTransferManagerDelegateArray {
                    (messageManagerDelegate as! MessageTransferManagerDelegate).receiveNewMessage?(message)
                }
                
            default:
                break
            }
        }
    }
    
    
    
//MARK: PushMessageDelegate
    
    func receivePushMessage(message: NSString) {
        if let message = MessageManager.messageModelWithMessage(message) {
            message.sendType = .MessageSendSomeoneElse
            messagePool.addMessage4Reorder(message)
        }
    }
    


//MARK: MessageReceivePoolDelegate
    
    func messgeReorderOver(messageList: NSDictionary) {
        for messageList in messageList.allValues {
            for message in (messageList as! NSMutableArray) {
                distributionMessage(message as? BaseMessage)
            }
        }

    }
}























