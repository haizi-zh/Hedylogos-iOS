//
//  MessageSendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol MessageSendDelegate {
    
}

class MessageSendManager: MessageTransferManager {
    var messageManagerDelegate: MessageTransferManagerDelegate?
    
    func asyncSendMessage(message: BaseMessage, receiver: Int, isChatGroup: Bool, completionBlock: (isSuccess: Bool, errorCode: Int)->()) {
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            daoHelper.insertChatMessage("chat_\(receiver)", message: message)
            daoHelper.closeDB()
        }
        
        for messageManagerDelegate in super.messageTransferManagerDelegateArray {
            (messageManagerDelegate as! MessageTransferManagerDelegate).sendNewMessage?(message)
        }
        var accountManager = AccountManager.shareInstance()
        NetworkTransportAPI.asyncSendMessage(MessageManager.prepareMessage2Send(receiverId: receiver, senderId: accountManager.userId, message: message), completionBlock: { (isSuccess, errorCode) -> () in
            completionBlock(isSuccess: isSuccess, errorCode: errorCode)
            if isSuccess {
                for messageManagerDelegate in super.messageTransferManagerDelegateArray {
                    (messageManagerDelegate as! MessageTransferManagerDelegate).messageHasSended?(message)
                }
            }
        })
    }
    
    /**
    发送一组消息
    
    :param: messageArray    消息组
    :param: receiver        接受者
    :param: isChatGroup     是否是群聊
    :param: completionBlock 发送后的回掉
    */
    func asyncSendMessageArray(messageArray: NSArray, receiver: Int, isChatGroup: Bool, completionBlock: (isSuccess: Bool, errorCode: Int)->()) {
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            for message in messageArray {
                daoHelper.insertChatMessage("chat_\(receiver)", message: (message as! BaseMessage))
            }
            daoHelper.closeDB()
        }
    }
}
